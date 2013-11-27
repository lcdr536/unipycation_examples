:- use_module(minimax).

board_width(7).
board_height(6).

direction(v(1, 0), horizontal).
direction(v(0, 1), vertical).
direction(v(1, 1), lrdiagonal).
direction(v(-1, 1), rldiagnoal).

choose_base_on_color(Reds, _, red, Reds).
choose_base_on_color(_, Yellows, yellow, Yellows).

search_vector(_, _, _, Required, Required).
search_vector(Coins, c(X, Y), v(Xd, Yd), Required, Ct) :-
    board_width(W), -1 < X, X < W,
    board_height(H), -1 < Y, Y < H,
    member(c(X, Y), Coins),
    NextCt is Ct + 1,
    NextX is X + Xd,
    NextY is Y + Yd,
    search_vector(Coins, c(NextX, NextY), v(Xd, Yd), Required, NextCt).

find_consecutive(Coins, Required, C) :-
    direction(Vec, _),
    search_vector(Coins, C, Vec, Required, 0).

has_won(Reds, Yellows, Color) :-
    choose_base_on_color(Reds, Yellows, Color, Coordinates),
    member(C, Coordinates),
    find_consecutive(Coordinates, 4, C), !.

% Test case
% Note the validity of the board is not checked.
main(Winner):-
    Reds = [ c(1, 1), c(2, 2), c(3, 3), c(4, 4) ],
    Yellows = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
    has_won(Reds, Yellows, Winner).

% ---/// Stuff for the minimax solver ///---

% Let's say Pos is:
% pos(Reds, Yellows, WhoseMove)

% Collects the cost of the game with respect to the incoming pos
% Note that the board state is not checked to be valid.
staticval(pos(RedCounters, YellowCounters, _), WinVal) :-
    has_won(RedCounters, YellowCounters, WhoWon), !,
    choose_base_on_color(-99999, 99999, WhoWon, WinVal), !. % heavy weights for win

staticval(pos(RedCounters, YellowCounters, _), Val) :-
    staticval_player(RedCounters, ValRed),
    staticval_player(YellowCounters, ValYellow),
    Val is ValYellow - ValRed.

% Collects the score of a single player's counters.
staticval_player(PlayersCounters, Val) :-
    findall(1, (
        member(WorkCounter, PlayersCounters),
        find_consecutive(PlayersCounters, 2, WorkCounter)
    ), List),
    length(List, Val).

% Finds how high a token would sit when inserted
get_insert_y(Toks, Col, YVal) :-
    board_height(H),
    get_insert_y(Toks, Col, H, YVal).

get_insert_y([], _, Min, YVal) :-
    YVal is Min - 1.
get_insert_y([c(Col1, _) | Rest], Col, Min, YVal) :-
    Col1 \= Col,
    get_insert_y(Rest, Col, Min, YVal).
get_insert_y([c(Col, Y) | Rest], Col, Min, YVal) :-
    NewMin is min(Y, Min),
    get_insert_y(Rest, Col, NewMin, YVal).

% Computes the new board state should we insert a token
insert_token(pos(Reds, Yellows, WhoseMove), Col, Move) :-
    append(Reds, Yellows, AllToks),
    get_insert_y(AllToks, Col, Y),
    choose_base_on_color(pos([c(Col, Y) | Reds], Yellows, yellow),
                         pos(Reds, [c(Col, Y) | Yellows], red),
                         WhoseMove, Move).

% Nasty hack to work around lack of proper list conversion
% over the language boundary. XXX
shuffle(In, Out) :-
    Hack =.. [xxx | In ],
    python:shuffle_moves(Hack, Shuffled),
    Shuffled =.. [ xxx | Out ].

% Find all possible subsequent game states
moves(pos(Reds, Yellows, _), []) :- % if someone won, dont collect moves
    has_won(Reds, Yellows, _), !.

moves(Pos, Moves) :-
    board_width(Width), Col is Width - 1,
    findall(Move, moves(Pos, Move, Col), MovesOrdered),
    shuffle(MovesOrdered, Moves).

moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
    board_width(W), Col < W, Col > -1,
    %board_height(H), TopSlot is H - 1,
    \+ member(c(Col, 0), Reds),
    \+ member(c(Col, 0), Yellows),
    insert_token(pos(Reds, Yellows, WhoseMove), Col, Move). % space in this col
moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
    Col > -1, NextCol is Col - 1,
    moves(pos(Reds, Yellows, WhoseMove), Move, NextCol). % search next col

min_to_move(pos(_, _, red)).
max_to_move(pos(_, _, yellow)).

% Just testing
test(GoodPos, Val) :-
    Reds = [c(0, 0), c(0, 1), c(0, 2)],
    Yellows = [],
    Pos = pos(Reds, Yellows, red),
    alphabeta(Pos, -99999, 99999, GoodPos, Val, 6).
:- use_module(minimax).

board_width(7).
board_height(6).

direction(v(1, 0), horizontal).
direction(v(0, 1), vertical).
direction(v(1, 1), lrdiagonal).
direction(v(-1, 1), rldiagnoal).

member1(E, [E | _]).
member1(E, [_ | T]) :-
	member1(E, T).
	
search_vector(_, _, _, Required, Required).
search_vector(COINS, c(X, Y), v(XD, YD), Required, CT) :-
	board_width(W), -1 < X, X < W,
	board_height(H), -1 < Y, Y < H,
	member1(c(X, Y), COINS),
	NEXT_CT is CT + 1,
	NEXT_X is X + XD,
	NEXT_Y is Y + YD,
	search_vector(COINS, c(NEXT_X, NEXT_Y), v(XD, YD), Required, NEXT_CT).

find_consecutive(COINS, Required, C) :-
	direction(VEC, _),
	search_vector(COINS, C, VEC, Required, 0).
	%format("~p win at ~p~n", [DESCR, C]).

has_won(REDS, _, red) :-
	member1(C, REDS),
	find_consecutive(REDS, 4, C), !.

has_won(_, YELLOWS, yellow) :-
	member1(C, YELLOWS),
	find_consecutive(YELLOWS, 4, C), !.

% Test case
% Note the validity of the board is not checked.
main(WINNER):-
	REDS = [ c(1, 1), c(2, 2), c(3, 3), c(4, 4) ],
	YELLOWS = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
	has_won(REDS, YELLOWS, WINNER).

% ---/// Stuff for the minimax solver ///---

% Let's say Pos is:
% pos(Reds, Yellows, WhoseMove)

% Collects the cost of the game with respect to the incoming pos
% Note that the board state is not checked to be valid.
staticval(pos(RedCounters, YellowCounters, _), Val) :-
	staticval_player(RedCounters, RedCounters, ValRed),
	staticval_player(YellowCounters, YellowCounters, ValYellow),
	%format("Red ~k vs Yellow ~k~n", [ValRed, ValYellow]),
	Val is ValRed - ValYellow.

% Collects the score of a single player's counters.
staticval_player(_, [], 0). % No work left, we are done.
staticval_player(OnePlayersCounters, [WorkCounter | OtherWorkCounters], Val) :-
	staticval_counter(OnePlayersCounters, WorkCounter, CounterVal),
	staticval_player(OnePlayersCounters, OtherWorkCounters, OtherCounterVals),
	Val is CounterVal + OtherCounterVals.

% Collects the score of a single counter
staticval_counter(OnePlayersCounters, WorkCounter, CounterVal) :-
	findall(1, find_consecutive(OnePlayersCounters, 2, WorkCounter), List),
	length(List, CounterVal).

% Finds how high a token would sit when inserted
get_insert_y(Toks, Col, YVal) :-
	findall(Y, member(c(Col, Y), Toks), Ys),
	(length(Ys, 0) -> (
		YVal = 0
	); (
		max_member(TopY, Ys),
		YVal is TopY + 1
	)).

% Computes the new board state should we insert a token
insert_token(pos(Reds, Yellows, WhoseMove), Col, Move) :-
	append(Reds, Yellows, AllToks),
	get_insert_y(AllToks, Col, Y),
	(WhoseMove = red -> (
		append(Reds, [c(Col, Y)], NewReds),
		Move = pos(NewReds, Yellows, yellow)
	) ; (
		append(Yellows, [c(Col, Y)], NewYellows),
		Move = pos(Reds, NewYellows, red)
	)).

% Find all possible subsequent game states
moves(Pos, Moves) :-
	board_width(Width), Col is Width - 1,
	findall(Move, moves(Pos, Move, Col), Moves).

moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
	board_width(W), Col < W, Col > -1,
	board_height(H), TopSlot is H - 1,
	\+ member(c(Col, TopSlot), Reds),
	\+ member(c(Col, TopSlot), Yellows),
	insert_token(pos(Reds, Yellows, WhoseMove), Col, Move). % space in this col
moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
	Col > -1, NextCol is Col - 1,
	moves(pos(Reds, Yellows, WhoseMove), Move, NextCol). % search next col

% Just for debugging
print_moves([]).
print_moves([Move | Others]) :-
	staticval(Move, Val),
	%format("~p = ~p~n", [Move, Val]),
	write(Move),nl,
	write(Val),nl,
	print_moves(Others).

min_to_move(pos(_, _, red)).
max_to_move(pos(_, _, yellow)).
	
% Just testing
test(GoodPos, Val) :-
	Reds = [c(0, 0), c(0, 1)],
	Yellows = [c(1, 0), c(1, 1), c(2, 0)],
	Pos = pos(Reds, Yellows, red),
	alphabeta(Pos, -99999, 99999, GoodPos, Val, 10).
	%moves(Pos, Moves),
	%print_moves(Moves).
	%write(GoodPos), nl,
	%write(Val), nl.

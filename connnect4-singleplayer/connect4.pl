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

% Stuff for the minimax solver.

% Let's say Pos is:
% pos(reds, yellows)

% Collects the cost of the game with respect to the incoming pos
% Note that the board state is not checked to be valid.
staticval(pos(RedCounters, YellowCounters), Val) :-
	staticval_player(RedCounters, RedCounters, ValRed),
	staticval_player(YellowCounters, YellowCounters, ValYellow),
	format("Red ~k vs Yellow ~k~n", [ValRed, ValYellow]),
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

% Just testing
test(V) :-
	Reds = [ c(1, 1), c(2, 1), c(1, 2), c(6, 5), c(6, 4) ],
	Yellows = [ c(3, 1), c(4, 1), (5, 1), (6, 1)],
	staticval(pos(Reds, Yellows), V).

board_width(7).
board_height(6).

direction(v(1, 0), horizontal).
direction(v(0, 1), vertical).
direction(v(1, 1), lrdiagonal).
direction(v(-1, 1), rldiagnoal).

member1(E, [E | _]).
member1(E, [_ | T]) :-
	member1(E, T).
	
search_vector(_, _, _, 4).
search_vector(COINS, c(X, Y), v(XD, YD), CT) :-
	board_width(W), -1 < X, X < W,
	board_height(H), -1 < Y, Y < H,
	member1(c(X, Y), COINS),
	NEXT_CT is CT + 1,
	NEXT_X is X + XD,
	NEXT_Y is Y + YD,
	search_vector(COINS, c(NEXT_X, NEXT_Y), v(XD, YD), NEXT_CT).

find_consecutive(COINS, C) :-
	direction(VEC, DESCR),
	search_vector(COINS, C, VEC, 0).
	%format("~p win at ~p~n", [DESCR, C]).

has_won(REDS, _, red) :-
	member1(C, REDS),
	find_consecutive(REDS, C), !.

has_won(_, YELLOWS, yellow) :-
	member1(C, YELLOWS),
	find_consecutive(YELLOWS, C), !.

% Test case
% Note the validity of the board is not checked.
main(WINNER):-
	REDS = [ c(1, 1), c(2, 2), c(3, 3), c(4, 4) ],
	YELLOWS = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
	has_won(REDS, YELLOWS, WINNER).

% Stuff for the minimax solver.

% Let's say Pos is:
% pos(reds, yellows, turn)
% 
% where turn is yellow/red

staticval(pos(reds, yellows, turn), Val) :-
	staticval_player(reds, reds, ValRed),
	staticval_player(yellows, yellows, ValYellow),
	Val is ValRed - ValYellow.

% Collects the score of a single player.
staticval_player(AllPlayerCounters, [], 0). % No work left, we are done.

staticval_player(AllPlayerCounters, [WorkCounter | OtherWorkCounters], Val) :-
	staticval_counter(AllPlayerCounters, WorkCounter, CounterVal),
	staticval_player(AllPlayerCounters, OtherWorkCounters, OtherCounterVals),
	Val is CounterVal + OtherCounterVals.

% Collects the score of a single counter
staticval_counter(AllPlayerCounters, WorkCounter, CounterVal) :-
	true. % XXX

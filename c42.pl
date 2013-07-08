board_width(7).
board_height(6).

direction(v(1, 0), horizontal).
direction(v(0, 1), vertical).
direction(v(1, 1), lrdiagonal).
direction(v(-1, 1), rldiagnoal).

search_vector(_, _, _, 4).
search_vector(COINS, c(X, Y), v(XD, YD), CT) :-
	board_width(W), -1 < X, X < W,
	board_height(H), -1 < Y, Y < H,
	member(c(X, Y), COINS),
	NEXT_CT is CT + 1,
	NEXT_X is X + XD,
	NEXT_Y is Y + YD,
	search_vector(COINS, c(NEXT_X, NEXT_Y), v(XD, YD), NEXT_CT).

find_consecutive(COINS, C) :-
	direction(VEC, DESCR),
	search_vector(COINS, C, VEC, 0),
	format("~p win at ~p~n", [DESCR, C]).

has_won(REDS, _, red) :-
	member(C, REDS),
	find_consecutive(REDS, C), !.

has_won(_, YELLOWS, yellow) :-
	member(C, YELLOWS),
	find_consecutive(YELLOWS, C), !.

% Test case
% Note the validity of the board is not checked.
main(WINNER):-
	REDS = [ c(1, 1), c(2, 2), c(3, 3), c(4, 4) ],
	YELLOWS = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
	has_won(REDS, YELLOWS, WINNER).
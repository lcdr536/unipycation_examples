board_width(7).
board_height(6).

search_vector(_, _, _, 4) :- !.
search_vector(COINS, c(X, Y), v(XD, YD), CT) :-
	board_width(W), -1 < X, X < W,
	board_height(H), -1 < Y, Y < H,
	member(c(X, Y), COINS),
	NEXT_CT is CT + 1,
	NEXT_X is X + XD,
	NEXT_Y is Y + YD,
	search_vector(COINS, c(NEXT_X, NEXT_Y), v(XD, YD), NEXT_CT), !.

find_consecutive(COINS, c(X, Y)) :-
	search_vector(COINS, c(X, Y), v(1, 0), 0), % search right
	format("horizontal win at (~p, ~p)~n", [X, Y]), !.
find_consecutive(COINS, c(X, Y)) :-
	search_vector(COINS, c(X, Y), v(0, 1), 0), % search down
	format("vertical win at (~p, ~p)~n", [X, Y]), !.
find_consecutive(COINS, c(X, Y)) :-
	search_vector(COINS, c(X, Y), v(1, 1), 0), % search lr diag
	format("LR-diagonal win at (~p, ~p)~n", [X, Y]), !.
find_consecutive(COINS, c(X, Y)) :-
	search_vector(COINS, c(X, Y), v(-1, 1), 0), % search rl diag
	format("RL-diagonal win at (~p, ~p)~n", [X, Y]), !.

has_won(REDS, _, red) :-
	member(C, REDS),
	find_consecutive(REDS, C), !.

has_won(_, YELLOWS, yellow) :-
	member(C, YELLOWS),
	find_consecutive(YELLOWS, C), !.

% Test case
% Note the validity of the board is not checked.
main(WINNER):-
	REDS = [ c(1, 1), c(4, 2), c(3, 3), c(4, 4) ],
	YELLOWS = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
	has_won(REDS, YELLOWS, WINNER).

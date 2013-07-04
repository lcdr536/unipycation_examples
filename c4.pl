print_board([]).
print_board([ TOPROW | REST ]) :-
	format('~p~n', [TOPROW]), print_board(REST).

get_row(1, [TOPROW | _], TOPROW).
get_row(N, [_ | REST], OUT) :-
	NP is N - 1,
	get_row(NP, REST, OUT).

get_col(_, [], []).
get_col(N, [TOPROW | OTHERROWS], OUT) :-
	get_col(N, OTHERROWS, OTHERNEW),
	get_elem(N, TOPROW, NEW),
	OUT = [ NEW | OTHERNEW ].

% Although they hold different meaning, are the same.
get_elem(N, ROW, OUT) :- get_row(N, ROW, OUT).

get_at(X, Y, BOARD, E) :-
	get_row(Y, BOARD, ROW),
	get_elem(X, ROW, E).
	
% XXX fill this in
has_won(BOARD, PLAYER) :-
	PLAYER = PLAYER,
	BOARD = BOARD. % Just to silence compiler for now
	
main :-
	BOARD = [[0, 0, 0, 0, 0, 0, 0],
		 [0, 0, 0, 0, 0, 0, 0],
		 [0, 0, 0, 0, 0, 0, 0],
		 [0, 0, 0, 1, 0, 0, 0],
		 [0, 0, 0, 2, 1, 0, 0],
		 [0, 1, 1, 1, 1, 2, 0]],
	 get_at(4, 6, BOARD, EL),
	 format('~p~n', [EL]),
	 (has_won(BOARD, 1); has_won(BOARD, 2)).

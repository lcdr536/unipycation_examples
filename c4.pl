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
	
has_won(_, _, WON) :-
	WON = true.
	
main(STOP) :-
	BOARD = [[1, 0, 0, 0, 0, 0, 0],
		 [0, 1, 0, 0, 0, 0, 0],
		 [0, 0, 1, 0, 0, 0, 0],
		 [0, 0, 0, 1, 0, 0, 0],
		 [0, 0, 0, 0, 1, 0, 0],
		 [0, 1, 1, 1, 1, 2, 0]],
	 get_col(1, BOARD, OUT),
	 format('~p~n', [OUT]),
	 has_won(BOARD, 1, STOP).

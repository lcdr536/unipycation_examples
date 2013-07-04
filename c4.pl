board_width(7).

print_board([]).
print_board([ TOPROW | REST ]) :-
	format('~p~n', [TOPROW]), print_board(REST).

get_row([TOPROW | _], 1, TOPROW) :- !.
get_row([_ | REST], N, OUT) :-
	NP is N - 1,
	get_row(REST, NP, OUT).

get_col([], _, []).
get_col([TOPROW | OTHERROWS], N, OUT) :-
	get_col(OTHERROWS, N, OTHERNEW),
	get_elem(TOPROW, N, NEW),
	OUT = [ NEW | OTHERNEW ].

% Although they hold different meaning, are the same.
get_elem(ROW, N, OUT) :- get_row(ROW, N, OUT).

get_at(BOARD, X, Y, E) :-
	get_row(BOARD, Y, ROW),
	get_elem(ROW, X, E).


collect_left(ROW, X, PLAYER, COUNT) :-
	get_elem(ROW, X, E),
	format("Collect left (~p) ~p = ~p~n", [X, E, PLAYER]),
	E = PLAYER,
	format("Yep~n"),
	XP is X - 1,
	collect_left(ROW, XP, PLAYER, COUNTP),
	COUNT is COUNTP + 1.

collect_left(ROW, X, PLAYER, COUNT) :-
	get_elem(ROW, X, E),
	E \= PLAYER,
	COUNT = 0.

% If we fall of the left edge, stop searching
collect_left(_, 0, _, COUNT) :-
	COUNT = 0.

collect_right(ROW, X, PLAYER, COUNT) :-
	reverse(ROW, ROW_R),
	board_width(WIDTH),
	XR is (WIDTH + 1) - X,	% compute new offset
	collect_left(ROW_R, XR, PLAYER, COUNT).

% Count the number of tokens to the left of the same colour
find_consecutive(BOARD, X, Y, PLAYER) :-
	format("Check consecutive~n"),
	get_row(BOARD, Y, ROW),
	collect_left(ROW, X, PLAYER, COUNT_LEFT),
	format("LEFT: ~p~n", [COUNT_LEFT]),
	collect_right(ROW, X, PLAYER, COUNT_RIGHT),
	format("RIGHT: ~p~n",[COUNT_RIGHT]),
	COUNT_TOT is COUNT_LEFT + COUNT_RIGHT -1, % start counted twice,
	format("TOTAL: ~p~n", [COUNT_TOT]),
	COUNT_TOT >= 4.

search_row(BOARD, X, Y, [PLAYER | _], PLAYER) :-
	format("Match for player ~p found at (~p, ~p)~n", [PLAYER, X, Y]),
	find_consecutive(BOARD, X, Y, PLAYER).

search_row(BOARD, X, Y, [_ | T], PLAYER) :-	% no match head
	XP is X + 1,
	search_row(BOARD, XP, Y, T, PLAYER).

search(BOARD, Y, [TOPROW | _], PLAYER) :- % match in this row
	search_row(BOARD, 1, Y, TOPROW, PLAYER).
search(BOARD, Y, [_ | OTHERROWS], PLAYER) :- % Search other rows
	YP is Y + 1,
	search(BOARD, YP, OTHERROWS, PLAYER).
	
has_won(BOARD, PLAYER) :-
	search(BOARD, 1, BOARD, PLAYER).
	
main :-
	BOARD = [[1, 1, 1, 1, 0, 0, 0],
		 [0, 0, 0, 0, 0, 0, 0],
		 [0, 0, 0, 0, 0, 0, 0],
		 [0, 0, 0, 1, 0, 0, 0],
		 [0, 0, 0, 2, 1, 0, 0],
		 [0, 1, 1, 1, 1, 2, 0]],
	 (has_won(BOARD, 1); has_won(BOARD, 2)).

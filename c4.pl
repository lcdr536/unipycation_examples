board_width(7).
board_height(6).

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

get_lr_diag(BOARD, X, Y, SEQ) :-
        board_width(BW), board_height(BH),
        X =< BW, Y =< BH,
        XN is X + 1, YN is Y + 1,
        get_lr_diag(BOARD, XN, YN, SEQP),
        get_at(BOARD, X, Y, E),
        SEQ = [ E | SEQP ].

get_lr_diag(_, X, _, []) :-
        board_width(BW), X >= BW.

get_lr_diag(_, _, Y, []) :-
        board_height(BH), Y >= BH.

min(X, Y, X) :- X =< Y.
min(X, Y, Y) :- Y =< X.

get_lr_diag_root(X, Y, XP, YP) :-
        min(X, Y, MIN),
        XP is X - (MIN - 1),
        YP is Y - (MIN - 1).

%get_lr_diag_root(X, Y, XP, YP) :-
%X >= 1, Y >= 1,
%XN is X - 1, YN is Y - 1,
%get_lr_diag_root(BOARD, 

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
	length(ROW, LEN),
	XR is (LEN + 1) - X,	% compute new offset
	collect_left(ROW_R, XR, PLAYER, COUNT).

% Count the number of tokens to the left of the same colour
%find_consecutive(BOARD, X, Y, PLAYER) :-
find_consecutive(SEQ, X, PLAYER) :-
	format("Check consecutive~n"),
        % No need to collect left, will be eventually found
        %collect_left(SEQ, X, PLAYER, COUNT_LEFT),
        %format("LEFT: ~p~n", [COUNT_LEFT]),
	collect_right(SEQ, X, PLAYER, COUNT_RIGHT),
	format("RIGHT: ~p~n",[COUNT_RIGHT]),
        %COUNT_TOT is COUNT_LEFT + COUNT_RIGHT -1, % start counted twice,
        %format("TOTAL: ~p~n", [COUNT_TOT]),
	COUNT_RIGHT >= 4.

check_win_horiz(BOARD, X, Y, PLAYER) :-
        get_row(BOARD, Y, ROW),
	find_consecutive(ROW, X, PLAYER).

check_win_vert(BOARD, X, Y, PLAYER) :-
        get_col(BOARD, X, COL),
	find_consecutive(COL, Y, PLAYER).

check_win_lr_diag(BOARD, X, Y, PLAYER) :-
        X = 2, Y = 3, % XXX
        get_lr_diag(BOARD, X, Y, DIAG),
	find_consecutive(DIAG, 1, PLAYER).

check_win(BOARD, X, Y, PLAYER) :- check_win_horiz(BOARD, X, Y, PLAYER).
check_win(BOARD, X, Y, PLAYER) :- check_win_vert(BOARD, X, Y, PLAYER).
check_win(BOARD, X, Y, PLAYER) :- check_win_lr_diag(BOARD, X, Y, PLAYER).

search_row(BOARD, X, Y, [PLAYER | _], PLAYER) :-
	format("Match for player ~p found at (~p, ~p)~n", [PLAYER, X, Y]),
        check_win(BOARD, X, Y, PLAYER).

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
	BOARD = [[1, 0, 1, 1, 0, 0, 0],
		 [0, 0, 0, 0, 0, 0, 0],
		 [0, 1, 0, 0, 0, 1, 0],
		 [0, 0, 1, 0, 0, 0, 0],
		 [0, 0, 0, 1, 0, 0, 0],
		 [0, 0, 1, 1, 1, 2, 0]],
         (has_won(BOARD, 1), format("Player one wins~n");
         has_won(BOARD, 2), format("Player two wins~n")).

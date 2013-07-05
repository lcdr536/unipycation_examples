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

get_rl_diag(BOARD, X, Y, SEQ) :-
        board_height(BH),
        X >= 1, Y =< BH,
        XN is X - 1, YN is Y + 1,
        get_rl_diag(BOARD, XN, YN, SEQP),
        get_at(BOARD, X, Y, E),
        SEQ = [ E | SEQP ].

get_rl_diag(_, X, _, []) :- X =< 1.
get_rl_diag(_, _, Y, []) :- board_height(BH), Y >= BH.

% Although they hold different meaning, are the same.
get_elem(ROW, N, OUT) :- get_row(ROW, N, OUT).

get_at(BOARD, X, Y, E) :-
	get_row(BOARD, Y, ROW),
	get_elem(ROW, X, E).

collect_right(ROW, X, PLAYER, COUNT) :-
	get_elem(ROW, X, E),
	E = PLAYER, XP is X + 1,
	collect_right(ROW, XP, PLAYER, COUNTP),
	COUNT is COUNTP + 1.

collect_right(ROW, X, PLAYER, COUNT) :-
	get_elem(ROW, X, E),
	E \= PLAYER,
	COUNT = 0.

% If we fall of the edge, stop searching
collect_right(SEQ, X, _, COUNT) :-
        length(SEQ, LEN), X =:= LEN + 1,
	COUNT = 0.

% Count the number of tokens to the left of the same colour
find_consecutive(SEQ, X, PLAYER) :-
	collect_right(SEQ, X, PLAYER, COUNT_RIGHT),
	COUNT_RIGHT >= 4.

check_win_horiz(BOARD, X, Y, PLAYER) :-
        get_row(BOARD, Y, ROW),
	find_consecutive(ROW, X, PLAYER),
        format("Horizontal win @ (~p, ~p) for player ~p~n", [X, Y, PLAYER]).

check_win_vert(BOARD, X, Y, PLAYER) :-
        X = 2, Y = 2,
        get_col(BOARD, X, COL),
	find_consecutive(COL, Y, PLAYER),
        format("Vertical win @ (~p, ~p) for player ~p~n", [X, Y, PLAYER]).

check_win_lr_diag(BOARD, X, Y, PLAYER) :-
        get_lr_diag(BOARD, X, Y, DIAG),
	find_consecutive(DIAG, 1, PLAYER),
        format("LR diagonal win @ (~p, ~p) for player ~p~n", [X, Y, PLAYER]).

check_win_rl_diag(BOARD, X, Y, PLAYER) :-
        get_rl_diag(BOARD, X, Y, DIAG),
	find_consecutive(DIAG, 1, PLAYER),
        format("RL diagonal win @ (~p, ~p) for player ~p~n", [X, Y, PLAYER]).

check_win(BOARD, X, Y, PLAYER) :- check_win_horiz(BOARD, X, Y, PLAYER).
check_win(BOARD, X, Y, PLAYER) :- check_win_vert(BOARD, X, Y, PLAYER).
check_win(BOARD, X, Y, PLAYER) :- check_win_lr_diag(BOARD, X, Y, PLAYER).
check_win(BOARD, X, Y, PLAYER) :- check_win_rl_diag(BOARD, X, Y, PLAYER).

search_row(BOARD, X, Y, [PLAYER | _], PLAYER) :-
        check_win(BOARD, X, Y, PLAYER).

search_row(BOARD, X, Y, [_ | T], PLAYER) :-
	XP is X + 1,
	search_row(BOARD, XP, Y, T, PLAYER).

search(BOARD, Y, [TOPROW | _], PLAYER) :-
	search_row(BOARD, 1, Y, TOPROW, PLAYER).

search(BOARD, Y, [_ | OTHERROWS], PLAYER) :-
	YP is Y + 1,
	search(BOARD, YP, OTHERROWS, PLAYER).
	
has_won(BOARD, PLAYER) :-
	search(BOARD, 1, BOARD, PLAYER).
	
main :-
        % The board is not checked to be valid
        % The ui can do that.
	BOARD = [[1, 0, 1, 1, 0, 0, 0],
		 [0, 1, 0, 0, 0, 0, 0],
		 [0, 1, 0, 0, 0, 1, 0],
                 [1, 0, 0, 0, 1, 0, 0],
		 [0, 1, 0, 0, 0, 0, 0],
		 [0, 1, 1, 1, 1, 2, 0]],
         (has_won(BOARD, 1), format("Player one wins~n");
         has_won(BOARD, 2), format("Player two wins~n")).

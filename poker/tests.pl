:- begin_tests(poker).
:- use_module(poker).

% XXX: This gives a "straight" instead of a "straight_flush"
test(straight_flush) :-
	Hand = [ card(7, c), card(8, c), card(9, c), card(10, c), card(j, c) ],
	findall(res(HandName, Match), hand(Hand, HandName, Match), Results),
	member(res(straight_flush,  Hand), Results).

test(four_of_a_kind) :-
	Hand = [ card(7, c), card(7, h), card(7, d), card(7, s) ],
	findall(res(HandName, Match), hand(Hand, HandName, Match), Results),
	format("~k\n", [Results]),
	memberchk(res(four_of_a_kind,  Hand), Results).

test(high_card, all(Match == [[card(4, s)]])) :-
	hand([card(4, s)], high_card, Match).

:- end_tests(poker).

:- begin_tests(poker).
:- use_module(poker).

% XXX: This gives a "straight" instead of a "straight_flush"
test(straight_flush) :-
	Hand = [ card(7, c), card(8, c), card(9, c), card(10, c), card(j, c) ],
	findall(Match, hand(Hand, straight_flush, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(four_of_a_kind) :-
	Hand = [ card(7, c), card(7, h), card(7, d), card(7, s) ],
	findall(Match, hand(Hand, four_of_a_kind, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(full_house) :-
	Hand = [ card(7, c), card(7, h), card(7, d), card(5, h), card(5, d) ],
	findall(Match, hand(Hand, full_house, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(flush) :-
	Hand = [ card(7, h), card(2, h), card(3, h), card(j, h), card(k, h) ],
	findall(Match, hand(Hand, flush, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(straight) :-
	Hand = [ card(7, c), card(8, h), card(9, d), card(10, c), card(j, c) ],
	findall(Match, hand(Hand, straight, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(three_of_a_kind) :-
	Hand = [ card(7, h), card(7, d), card(7, s) ],
	findall(Match, hand(Hand, three_of_a_kind, Match), Results),
	length(Results, 1),
	Results = [ Res | _ ],
	findall(HandPerm, permutation(Hand, HandPerm), Perms),
	memberchk(Res, Perms).

test(high_card, all(Match == [[card(4, s)]])) :-
	hand([card(4, s)], high_card, Match).

:- end_tests(poker).

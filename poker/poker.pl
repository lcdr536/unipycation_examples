:- module(poker, [main/2]).

% XXX needs to go into pyrolog
select(X, [X|Tail], Tail).
select(Elem, [Head|Tail], [Head|Rest]) :-
	select(Elem, Tail, Rest).

% XXX needs to go into pyrolog
nextto(X, Y, [X,Y|_]).
nextto(X, Y, [_|Zs]) :-
	nextto(X, Y, Zs).

% XXX needs to go into pyrolog
subtract([], _, []) :- !.
subtract([E|T], D, R) :-
	memberchk(E, D), !,
	subtract(T, D, R).
subtract([H|T], D, [H|R]) :-
	subtract(T, D, R).

% XXX needs to go into pyrolog
memberchk(Elem, List) :-
	once(member(Elem, List)).

value_order([2, 3, 4, 5, 6, 7, 8, 9, 10, j, q, k, a ]).

next_in_value(card(Val1, _), card(Val2, _)) :-
	value_order(L),
	nextto(Val1, Val2, L).

pick(H, [H | T], T).
pick(H, [_ | T], T2) :- pick(H, T, T2).

of_a_kind(Cards, NReq, Result) :-
        of_a_kind(Cards, NReq, _, Result).

of_a_kind(_, 0, _, []).
of_a_kind(Cards, NReq, Val, [card(Val, St) | Rest]) :-
        NReq > 0, NReqNext is NReq - 1,
        pick(card(Val, St), Cards, Cards2),
        of_a_kind(Cards2, NReqNext, Val, Rest).

consecutive_values(Cards, NReq, Match) :-
	select(Card, Cards, Cards2),
	consecutive_values(Cards2, Card, NReq, Match).

consecutive_values(_, C1, 1, [C1]).
consecutive_values(Cards, C1, NReq, [ C1 | Match]) :-
        NReq > 1, NReqNext is NReq - 1,
	next_in_value(C1, C2),
	select(C2, Cards, Cards2),
	consecutive_values(Cards2, C2, NReqNext, Match).

same_suit(Cards, NReq, Match) :-
	same_suit(Cards, NReq, _, Match).

same_suit(_, 0, _, []).
same_suit(Cards, NReq, Suit, [ card(Val, Suit) | NextMatch ]) :-
        NReq > 1, NReqNext is NReq - 1,
	pick(card(Val, Suit), Cards, CardsRemain),
	same_suit(CardsRemain, NReqNext, Suit, NextMatch).

select_n(_, 0, []).
select_n(Cards, N, Selection) :-
	select(C, Cards, CardsRemain),
	NextN is N - 1,
	Selection = [ C | NextSelection ],
	select_n(CardsRemain, NextN, NextSelection).

% ---[ Begin Winning Hands ]------------------------------------------

hand(Cards, four_of_a_kind, Match) :-
	of_a_kind(Cards, 4, Match).

hand(Cards, Flush, Match) :-
        same_suit(Cards, 5, Match),
        select_flush_kind(Match, Flush).

hand(Cards, full_house, Match) :-
	of_a_kind(Cards, 3, MatchThree),
	subtract(Cards, MatchThree, RemainCards),
	of_a_kind(RemainCards, 2, MatchTwo),
	append(MatchTwo, MatchThree, Match).

hand(Cards, straight, Match) :-
	consecutive_values(Cards, 5, Match).

hand(Cards, three_of_a_kind, Match) :-
	of_a_kind(Cards, 3, Match).

hand(Cards, two_pair, Match) :-
	of_a_kind(Cards, 2, Match1),
	subtract(Cards, Match1, RemainCards),
	of_a_kind(RemainCards, 2, Match2),
	append(Match2, Match1, Match).

hand(Cards, one_pair, Match) :-
	of_a_kind(Cards, 2, Match).

hand(Cards, high_card, Match) :-
	select(C, Cards, _),
	Match = [ C ].

% ugly :-(
select_flush_kind(Cards, Flush) :-
    consecutive_values(Cards, 5, Match) -> (
        Match = [H | _],
        H = card(10, _) -> Flush = royal_flush; Flush = straight_flush
    ) ; (
        Flush = flush
    ).


% ---[ Just for testing ]---------------------------------------------

main(Handname, Match) :-
    Cards = [
          card(9, diamonds),
          card(9, clubs),
          card(9, hearts),
          card(3, diamonds),
          card(3, clubs),
          card(3, hearts)
      ],
    hand(Cards, Handname, Match).

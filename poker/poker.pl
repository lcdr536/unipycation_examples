:- module(poker, [main/2]).

no_permutations(CARDS) :-
	sort(CARDS, CARDS_SORTED),
	CARDS = CARDS_SORTED.

value_order([2, 3, 4, 5, 6, 7, 8, 9, 10, j, q, k, a ]).

next_in_value(card(VAL1, _), card(VAL2, _)) :-
    value_order(L),
    nextto(VAL1, VAL2, L).

of_a_kind(CARDS, N_REQ, MATCH) :-
    member(card(VAL, _), CARDS),
    of_a_kind(CARDS, N_REQ, VAL, MATCH), !.

of_a_kind(_, 0, _, []).
of_a_kind(CARDS, N_REQ, VAL, MATCH) :-
    select(card(VAL, ST), CARDS, CARDS2),
    N_REQ_NEXT is N_REQ - 1,
    MATCH = [ card(VAL, ST) | NEXT_MATCH ],
    of_a_kind(CARDS2, N_REQ_NEXT, VAL, NEXT_MATCH).

consecutive_values(CARDS, N_REQ, MATCH) :-
    select(CARD, CARDS, CARDS2),
    consecutive_values(CARDS2, CARD, N_REQ, MATCH).

consecutive_values(_, C1, 1, [C1]).
consecutive_values(CARDS, C1, N_REQ, MATCH) :-
    select(C2, CARDS, CARDS2),
    next_in_value(C1, C2),
    MATCH = [ C1 | NEXT_MATCH],
    N_REQ_NEXT is N_REQ - 1,
    consecutive_values(CARDS2, C2, N_REQ_NEXT, NEXT_MATCH).

same_suit(CARDS, N_REQ, MATCH) :-
    same_suit(CARDS, N_REQ, _, MATCH), !.

same_suit(_, 0, _, []).
same_suit(CARDS, N_REQ, SUIT, MATCH) :-
	select(card(VAL, SUIT), CARDS, CARDS_REMAIN),
	N_REQ_NEXT is N_REQ - 1,
	MATCH = [ card(VAL, SUIT) | NEXT_MATCH ],
	same_suit(CARDS_REMAIN, N_REQ_NEXT, SUIT, NEXT_MATCH).

select_n(_, 0, []).
select_n(CARDS, N, SELECTION) :-
	select(C, CARDS, CARDS_REMAIN),
	NEXT_N is N - 1,
	SELECTION = [ C | NEXT_SELECTION ],
	select_n(CARDS_REMAIN, NEXT_N, NEXT_SELECTION).

% ---[ Begin Winning Hands ]------------------------------------------

hand(CARDS, four_of_a_kind, MATCH) :-
    of_a_kind(CARDS, 4, MATCH).

hand(CARDS, straight_flush, MATCH) :-
    consecutive_values(CARDS, 5, MATCH),
    same_suit(MATCH, 5, _),
    MATCH = [ H | _ ],
    H \= card(10, _).

hand(CARDS, royal_flush, MATCH) :-
    consecutive_values(CARDS, 5, MATCH),
    same_suit(MATCH, 5, _),
    MATCH = [ H | _ ],
    H = card(10, _).

hand(CARDS, full_house, MATCH) :-
	of_a_kind(CARDS, 3, MATCH_THREE),
	subtract(CARDS, MATCH_THREE, REMAIN_CARDS),
	of_a_kind(REMAIN_CARDS, 2, MATCH_TWO),
	append(MATCH_TWO, MATCH_THREE, MATCH).
	%no_permutations(MATCH).

hand(CARDS, flush, MATCH) :-
	select_n(CARDS, 5, MATCH),
	same_suit(MATCH, 5, _).
	%no_permutations(MATCH).

hand(CARDS, straight, MATCH) :-
	consecutive_values(CARDS, 5, MATCH).

hand(CARDS, three_of_a_kind, MATCH) :-
    of_a_kind(CARDS, 3, MATCH).

hand(CARDS, two_pair, MATCH) :-
	of_a_kind(CARDS, 2, MATCH1),
	subtract(CARDS, MATCH1, REMAIN_CARDS),
	of_a_kind(REMAIN_CARDS, 2, MATCH2),
	append(MATCH2, MATCH1, MATCH).

hand(CARDS, one_pair, MATCH) :-
    of_a_kind(CARDS, 2, MATCH).

hand(CARDS, high_card, MATCH) :-
	select(C, CARDS, _),
	MATCH = [ C ].

% ---[ Just for testing ]---------------------------------------------

main(HANDNAME, MATCH) :-
    CARDS = [
          card(9, diamonds),
          card(9, clubs),
          card(9, hearts),
          card(3, diamonds),
          card(3, clubs),
          card(3, hearts)
      ],
    sort(CARDS, CARDS_SORTED),
    hand(CARDS_SORTED, HANDNAME, MATCH).

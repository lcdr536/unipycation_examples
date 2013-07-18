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

same_suit(CARDS) :-
    select(card(_, SUIT), CARDS, CARDS_REMAIN),
    all_suit(CARDS_REMAIN, SUIT), !.

all_suit([], _).
all_suit(CARDS, SUIT) :-
	select(card(_, SUIT), CARDS, CARDS2),
	all_suit(CARDS2, SUIT).

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
    same_suit(MATCH),
    MATCH = [ H | _ ],
    H \= card(10, _).

hand(CARDS, royal_flush, MATCH) :-
    consecutive_values(CARDS, 5, MATCH),
    same_suit(MATCH),
    MATCH = [ H | _ ],
    H = card(10, _).

hand(CARDS, full_house, MATCH) :-
	of_a_kind(CARDS, 3, MATCH_THREE),
	subtract(CARDS, MATCH_THREE, REMAIN_CARDS),
	of_a_kind(REMAIN_CARDS, 2, MATCH_TWO),
	append(MATCH_TWO, MATCH_THREE, MATCH).

hand(CARDS, flush, MATCH) :-
	select_n(CARDS, 5, MATCH),
	same_suit(MATCH).

hand(CARDS, straight, MATCH) :-
	consecutive_values(CARDS, 5, MATCH).

hand(CARDS, three_of_a_kind, MATCH) :-
    of_a_kind(CARDS, 3, MATCH).

% ---[ Just for testing ]---------------------------------------------

main(HANDNAME, MATCH) :-
    CARDS = [
          card(9, diamonds),
          card(10, diamonds),
          card(j, diamonds),
          card(q, diamonds),
          card(q, hearts),
          card(q, clubs),
          card(k, diamonds),
          card(a, diamonds)
      ],
    hand(CARDS, HANDNAME, MATCH).

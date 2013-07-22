import Tkinter as tk
import uni, random, copy

class Card(object):
    """ Represents a single playing card """

    suitnames = { "s" : "spades", "c" : "clubs", \
            "h" : "hearts", "d" : "diamonds" }

    def __init__(self, val, suit):
        self.value = val
        self.suit = suit.lower()

    def to_term(self, engine):
        return engine.terms.card(val, suit)

    def __str__(self):
        return "Card: %2s of %s" % (self.value, Card.suitnames[self.suit])

class RandomHands(object):
    """ The Game GUI itself """

    # Only 52 cards, so no problem generating the whole deck
    full_deck = [ Card(v, s) for v in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "j", "q", "k", "a"] for s in "cshd"]

    def __init__(self):
        self.top = tk.Tk()
        self.top.title("Random Poker Hands")

        with open("poker.pl", "r") as fh: pdb = fh.read()
        self.engine = uni.Engine(pdb)

    @staticmethod
    def _draw_random(deck):
        card = random.choice(deck)
        deck.remove(card)
        return card

    def _gen_hand(self, size=7):
        deck = copy.copy(RandomHands.full_deck)
        hand = [ RandomHands._draw_random(deck) for x in range(size) ]

        for i in hand:
            print(i)

if __name__ == "__main__":
    g = RandomHands()
    g._gen_hand()

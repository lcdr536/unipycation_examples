import Tkinter as tk
import uni, random, copy

class Card(object):
    """ Represents a single playing card """

    suitnames = { "s" : "spades", "c" : "clubs", \
            "h" : "hearts", "d" : "diamonds" }

    def __init__(self, val, suit):
        self.value = val
        self.suit = suit.lower()
        
    def __getattr__(self, name):
        """ Images are generated lazily """
        if name == "image":
            w = tk.PhotoImage(file=self.image_filename())
            setattr(self, "image", w)
            return w

    def image_filename(self):
        return "images/%s%s.svg.gif" % (self.value.upper(), self.suit.upper())

    def to_term(self, engine):
        return engine.terms.card(val, suit)

    def __str__(self):
        return "Card: %2s of %s" % (self.value, Card.suitnames[self.suit])

class RandomHands(object):
    """ The Game GUI itself """


    def __init__(self):
        self.top = tk.Tk()

        # Only 52 cards, so no problem generating the whole deck
        # Has to happen after TK init.
        self.full_deck = [ Card(v, s) for \
                v in ["2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a"] for \
                s in "cshd"]

        self.top.title("Random Poker Hands")

        with open("poker.pl", "r") as fh: pdb = fh.read()
        self.engine = uni.Engine(pdb)

    @staticmethod
    def _draw_random(deck):
        card = random.choice(deck)
        deck.remove(card)
        return card

    def _gen_hand(self, size=7):
        deck = copy.copy(self.full_deck)
        return [ RandomHands._draw_random(deck) for x in range(size) ]

    def play(self):
        hand = self._gen_hand()
        images = [ x.image for x in hand ]
        widgets = [ tk.Label(image=x) for x in images ]

        for i in range(len(images)):
            widgets[i].grid(column=i + 1, row=0)
            #widgets[i].pack()

        text = tk.Label(text="Hand:", font=("Helvetica", 16))
        text.grid(column=0, row=0)

        self.top.mainloop()

if __name__ == "__main__":
    g = RandomHands()
    g.play()

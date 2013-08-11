import Tkinter as tk
import uni, random, copy

class Card(object):
    """ Represents a single playing card """

    suitnames = { "s" : "spades", "c" : "clubs", \
            "h" : "hearts", "d" : "diamonds" }

    def __init__(self, val, suit):
        self.value = val
        if suit is not None: self.suit = suit.lower()

    def __getattr__(self, name):
        """ Images are generated lazily """
        if name == "image":
            w = tk.PhotoImage(file=self.image_filename())
            setattr(self, "image", w)
            return w

    def image_filename(self):
        if self.value is None or self.suit is None: return "images/blank.svg.gif"
        return "images/%s%s.svg.gif" % (self.value.upper(), self.suit.upper())

    def to_term(self, engine):
        return engine.terms.card(self.value, self.suit)

    @staticmethod
    def from_term(c):
        assert isinstance(c, uni.Term) and c.name == "card"
        return Card(c.args[0], c.args[1])

    def __str__(self):
        return "Card: %2s of %s" % (self.value, Card.suitnames[self.suit])

class RandomHands(object):
    """ The Game GUI itself """

    HANDSIZE = 7

    def __init__(self):
        self.top = tk.Tk()
        self.scroll = tk.Scrollbar(self.top, orient=tk.VERTICAL)

        # Only 52 cards, so no problem generating the whole deck
        # Has to happen after TK init.
        self.full_deck = [ Card(v, s) for \
                v in ["2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a"] for \
                s in "cshd"]

        self.top.title("Unipycation: Random Poker Hands")

        with open("poker.pl", "r") as fh: pdb = fh.read()
        self.engine = uni.Engine(pdb)

        # Stuff for storing and showing results
        self.result_iter = None
        self.res_images = None # so we can erase them later
        self.handname_label = None # so we can erase it later

        # draw some of the gui
        sol_button = tk.Button(text="Next", command=self._show_next_result)
        sol_button.grid(column=1, row=1, columnspan=3)

        new_hand_button = tk.Button(text="New Hand", command=self._new_hand)
        new_hand_button.grid(column=4, row=1, columnspan=3)

        # Once there are no more solutions, we show blank "grayed out" cards
        self.blank_card = Card(None, None)
        self.blank_hand = [ self.blank_card for x in range(RandomHands.HANDSIZE) ]

    @staticmethod
    def _draw_random(deck):
        card = random.choice(deck)
        deck.remove(card)
        return card

    def _gen_hand(self):
        deck = copy.copy(self.full_deck)
        return [ RandomHands._draw_random(deck) for \
                x in range(RandomHands.HANDSIZE) ]

    def _find_winning_hands(self, hand):
        hand_as_terms = [ x.to_term(self.engine) for x in hand ]
        self.result_iter= self.engine.db.hand.iter(hand_as_terms, None, None)

    def _erase_result_from_gui(self):
        if self.res_images is not None:
            for i in self.res_images: i.grid_remove()
            self.handname_label.grid_remove()

    def _draw_row_of_cards(self, cards, labeltext, rowno):

        # Pad up to a hand size with blankers
        if len(cards) < RandomHands.HANDSIZE:
            pad = RandomHands.HANDSIZE - len(cards)
            cards += [ self.blank_card for x in range(pad) ]

        images = [ x.image for x in cards ]
        images_ws = [ tk.Label(image=x) for x in images ]

        for i in range(len(images)):
            images_ws[i].grid(column=i + 1, row=rowno)

        handname_label = tk.Label(width=10, text=labeltext, font=("Helvetica", 16))
        handname_label.grid(column=0, row=rowno)
        return (handname_label, images_ws)

    def _show_next_result(self):
        self._erase_result_from_gui()
        try:
            (hand_name, cards) = self.result_iter.next()
        except StopIteration:
            self._draw_row_of_cards(self.blank_hand, "No more", 2)
            return # No more

        card_objs = [ Card.from_term(x) for x in cards ]
        (self.handname_label, self.res_images) = self._draw_row_of_cards(card_objs, hand_name, 2)

    def _new_hand(self):
        hand = self._gen_hand()

        print(72 * "-")
        for i in hand:
            print(i)

        self._draw_row_of_cards(hand, "Hand:", 0)
        self._find_winning_hands(hand)
        self._show_next_result()

    def play(self):
        self._new_hand()
        self.top.mainloop()

if __name__ == "__main__":
    g = RandomHands()
    g.play()

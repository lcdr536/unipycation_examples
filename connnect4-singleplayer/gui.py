import Tkinter as tk
import uni

ROWS = 6
COLS = 7

def token_click_closure(c4, colno):
    return lambda : c4._insert(colno)

def tokengen():
    while True:
        yield "yellow"
        yield "red"

class Connect4(object):
    def __init__(self):
        self.top = tk.Tk()
        self.top.title("Unipycation: Connect 4 GUI (Python)")
        self.tokgen = tokengen()

        with open("connect4.pl", "r") as f: pdb = f.read()
        self.pl_engine = uni.Engine(pdb)

        self.cols = []
        self.insert_buttons = []
        for colno in range(COLS):
            col = []
            b = tk.Button(self.top, text=str(colno),
                    command=token_click_closure(self, colno))
            b.grid(column=colno, row=0)
            self.insert_buttons.append(b)

            for rowno in range(ROWS):
                b = tk.Button(self.top, state=tk.DISABLED)
                b.grid(column=colno, row=rowno + 1)
                col.append(b)
            self.cols.append(col)

        self.new_game_button = tk.Button(self.top, text="New Game", command=self._new)
        self.new_game_button.grid(column=COLS, row=0)

    def _end(self, winner_colour):
        for i in self.insert_buttons:
            i["state"] = tk.DISABLED
        self.new_game_button["background"] = winner_colour

    def _new(self):
        def_bg = self.top.cget('bg')
        for i in self.insert_buttons: i["state"] = tk.NORMAL

        for col in self.cols:
            for b in col:
                b["background"] = def_bg

        self.new_game_button["background"] = def_bg

    def play(self): self.top.mainloop()

    def _collect_token_coords(self, colour):
        """ makes a prolog list of coords of a given colour """
        assert colour in ["red", "yellow"]
        return [ (x, y) for x in range(COLS) for y in range(ROWS)
                if self.cols[x][y]["background"] == colour ]

    def _insert(self, colno):
        for but in reversed(self.cols[colno]):
            if but["background"] not in ["red", "yellow"]:
                but["background"] = self.tokgen.next()
                self._check_win()
                return
        print("column full, try again")

    def _check_win(self):
        reds = [ self.pl_engine.terms.c(x, y) for \
                (x, y) in self._collect_token_coords("red") ]
        yellows = [ self.pl_engine.terms.c(x, y) for \
                (x, y) in self._collect_token_coords("yellow") ]

        res = self.pl_engine.db.has_won(reds, yellows, None)
        if res is not None:
            (winner, ) = res
            print("%s wins" % winner)
            self._end(winner)

if __name__ == "__main__":
    g = Connect4()
    g.play()

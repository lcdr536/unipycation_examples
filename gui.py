import Tkinter as tk
import unipycation

ROWS = 6
COLS = 7

def token_click_closure(c4, colno):
    return lambda : c4.insert(colno)

def tokengen():
    while True:
        yield "yellow"
        yield "red"

class Connect4(object):
    def __init__(self):
        self.top = tk.Tk()
        self.tokgen = tokengen()

        with open("c42.pl", "r") as f: pdb = f.read()
        self.pl_engine = unipycation.Engine(pdb)

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

    def end(self):
        for i in self.insert_buttons:
            i["state"] = "disabled"

    def play(self): self.top.mainloop()

    def _collect_token_coords(self, colour):
        """ makes a prolog list of coords of a given colour """
        return [ (x, y) for x in range(COLS) for y in range(ROWS)
                if self.cols[x][y]["background"] == colour ]

    def insert(self, colno):
        for but in reversed(self.cols[colno]):
            if but["background"] not in ["red", "yellow"]:
                but["background"] = self.tokgen.next()
                self._check_win()
                break
        else:
            self.tokgen.next() # simulates "try again"

    def _check_win(self):

        reds = self._collect_token_coords("red")
        reds_p = "[" + ",".join([ "c(%d, %d)" % (x, y)for (x, y) in reds ]) + "]"

        yellows = self._collect_token_coords("yellow")
        yellows_p = "[" + ",".join([ "c(%d, %d)" % (x, y) for (x, y) in yellows ]) + "]"

        q = "has_won(%s, %s, W)." % (reds_p, yellows_p)
        print("<<<" + q + ">>>")
        it = self.pl_engine.query(q)

        try:
            winner = it.next()["W"]
            print("%s wins" % winner)
            self.end()
        except StopIteration:
            pass # no win yet

if __name__ == "__main__":
    g = Connect4()
    g.play()

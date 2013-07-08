import Tkinter as tk
import unipycation

ROWS = 6
COLS = 7

def tokengen():
    while True:
        yield "yellow"
        yield "red"

def collect_token_coords(cols, colour):
    """ makes a prolog list of coords of a given colour """
    coords = []
    for x in range(len(cols)):
        for y in range(len(cols[x])):
            if cols[x][y]["background"] == colour:
                coords.append("c(%d, %d)" % (x, y))

    return "[" + ",".join(coords) + "]"

def check_win(pl_engine, cols):
    reds = collect_token_coords(cols, "red")
    yellows = collect_token_coords(cols, "yellow")

    q = "has_won(%s, %s, W)." % (reds, yellows)
    print("<<<" + q + ">>>")
    it = pl_engine.query(q)

    try:
        winner = it.next()["W"]
        print("%s wins" % winner)
    except StopIteration:
        pass # no win yet

def insert_token(pl_engine, cols, tokgen, colno):

    for but in reversed(cols[colno]):
        if but["background"] not in ["red", "yellow"]:
            but["background"] = tokgen.next()
            check_win(pl_engine, cols)
            break
    else:
        tokgen.next() # simulates "try again"

def token_click_closure(pl_engine, cols, tokgen, colno):
    return lambda : insert_token(pl_engine, cols, tokgen, colno)

def make_gui():
    top = tk.Tk()

    tg = tokengen()

    with open("c42.pl", "r") as f: pdb = f.read()
    print(pdb)
    pl_engine = unipycation.Engine(pdb)

    cols = []
    for colno in range(COLS):
        col = []

        b = tk.Button(top, text=str(colno),
                command=token_click_closure(pl_engine, cols, tg, colno))
        b.grid(column=colno, row=0)

        for rowno in range(ROWS):
            b = tk.Button(top, state=tk.DISABLED)
            b.grid(column=colno, row=rowno + 1)
            col.append(b)
        cols.append(col)

    return top

if __name__ == "__main__":
    top = make_gui()
    top.mainloop()

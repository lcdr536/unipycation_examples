import Tkinter as tk

ROWS = 6
COLS = 7

def tokengen():
    while True:
        yield "yellow"
        yield "red"

def insert_token(cols, tokgen, colno):

    for but in reversed(cols[colno]):
        if but["background"] not in ["red", "yellow"]:
            but["background"] = tokgen.next()
            break
    else:
        tokgen.next() # simulates "try again"

def token_click_closure(cols, tokgen, colno):
        return lambda : insert_token(cols, tokgen, colno)

def make_gui():
    top = tk.Tk()

    cols = []
    for colno in range(COLS):
        col = []

        b = tk.Button(top, text=str(colno),
                command=token_click_closure(cols, tokengen(), colno))
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

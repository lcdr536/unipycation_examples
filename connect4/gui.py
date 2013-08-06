import Tkinter as tk
import uni, sys

ROWS = 6
COLS = 7

def token_click_closure(c4, colno):
    return lambda : c4._player_turn(colno)

class Connect4(object):
    UI_DEPTH = 5 # lookahead for minimax

    def __init__(self, p1_is_ai, p2_is_ai):
        self.top = tk.Tk()
        self.top.title("Unipycation: Connect 4 GUI (Python)")

        with open("connect4.pl", "r") as f: pdb = f.read()
        self.pl_engine = uni.Engine(pdb)

        # controls cpu/human players
        self.turn = None # True for p1, False for p2
        self.ai_players = { True : p1_is_ai, False : p2_is_ai }

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

        self.new_game_button = tk.Button(self.top, text="Start New Game", command=self._new)
        self.new_game_button.grid(column=COLS, row=0)

        self.status_text = tk.Label(self.top, text="---")
        self.status_text.grid(column=COLS, row=1)

    def _set_status_text(self, text):
        self.status_text["text"] = text

    def _end(self, winner_colour=None):
        for i in self.insert_buttons:
            i["state"] = tk.DISABLED

        if winner_colour is not None:
            self.new_game_button["background"] = winner_colour
            self._set_status_text("%s wins" % winner_colour)

    def _new(self):
        self.turn = False # first call to _turn will flip to True
        def_bg = self.top.cget('bg')
        for i in self.insert_buttons: i["state"] = tk.NORMAL

        for col in self.cols:
            for b in col:
                b["background"] = def_bg

        self.new_game_button["background"] = def_bg
        self._set_status_text("Your move")

        self._turn()

    def _turn(self):
        # Not pretty, but works...
        while True:
            self.turn = not self.turn # flip turn
            if self.ai_players[self.turn]:
                self._set_status_text("%s AI thinking" % (self._player_colour().title()))
                self._ai_turn()
                if self._check_win(): break # did the AI player win?
            else:
                self._set_status_text("%s human move" % (self._player_colour().title()))
                break # allow top loop to deal with human turn

    def play(self):
        self._end()
        self.top.mainloop()

    def _collect_token_coords(self, colour):
        """ makes a prolog list of coords of a given colour """
        assert colour in ["red", "yellow"]
        return [ (x, y) for x in range(COLS) for y in range(ROWS)
                if self.cols[x][y]["background"] == colour ]

    def _update_from_pos_one_colour(self, term_list, colour):
        assert colour in ["red", "yellow"]

        # XXX work around unipycation "bug"
        # Lists inside terms are not currently unwrapped
        # Iterative to avoid slicing
        def unwrap_prolog_list(cons):
            ret = []
            while cons != "[]":
                assert isinstance(cons, uni.Term)
                assert cons.name == "."
                ret.append(cons.args[0])
                cons = cons[1]
            return ret

        pylist = unwrap_prolog_list(term_list)
        for c in pylist:
            assert c.name == "c"
            (x, y) = (c.args[0], c.args[1])
            self.cols[x][y]["background"] = colour

    def _update_from_pos(self, pos):
        """ update the game state from the result of alphabeta """
        self._update_from_pos_one_colour(pos.args[0], "red")
        self._update_from_pos_one_colour(pos.args[1], "yellow")

    def _player_colour(self):
        return "red" if self.turn else "yellow"

    def _ai_turn(self):
        """ Let the AI take their turn. Uses minimax """

        self.top.update_idletasks() # redraw so we can see player's move

        # encode the current board and whose move (yellow for ai)
        (reds, yellows) = self._counters_to_terms()
        pos = self.pl_engine.terms.pos(reds, yellows, self._player_colour())

        (goodpos, val) = self.pl_engine.db.alphabeta(pos, -99999, 99999, None, None, Connect4.UI_DEPTH)
        self._update_from_pos(goodpos)

    def _player_turn(self, colno):
        """ Called when a human inserts a token """
        for but in reversed(self.cols[colno]):
            if but["background"] not in ["red", "yellow"]:
                but["background"] = self._player_colour()

                if self._check_win(): return # did the player win?
                self._turn() # next turn
                break
        print("column full, try again")

    def _counters_to_terms(self):
        """ convert the board to prolog terms """
        reds = [ self.pl_engine.terms.c(x, y) for \
                (x, y) in self._collect_token_coords("red") ]
        yellows = [ self.pl_engine.terms.c(x, y) for \
                (x, y) in self._collect_token_coords("yellow") ]
        return (reds, yellows)

    def _check_win(self):
        (reds, yellows) = self._counters_to_terms()

        res = self.pl_engine.db.has_won(reds, yellows, None)
        if res is not None:
            (winner, ) = res
            print("%s wins" % winner)
            self._end(winner)
            return True

        return False # no win

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print("usage: gui.py num_players")
        sys.exit(1)

    n = int(sys.argv[1])

    if n == 0:
        g = Connect4(True, True)
    elif n == 1:
        g = Connect4(False, True)
    elif n == 2:
        g = Connect4(False, False)
    else:
        print("0/1/2 players")
        sys.exit(1)

    g.play()

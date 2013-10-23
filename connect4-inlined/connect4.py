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

        self.pl_engine = uni.Engine("""

% Figure 22.5  An implementation of the alpha-beta algorithm.
% Based upon code from the book:
% Prolog Programming for Artificial Intelligence
% http://www.iro.umontreal.ca/~nie/IFT3335/Bratko/fig22_5.pl

% The alpha-beta algorithm
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth)  :-
    user:moves(Pos, PosList), !,
    Depth0 is Depth - 1,
    alphabetamoves(PosList, Pos, Alpha, Beta, GoodPos, Val, Depth0).

alphabetamoves([], Pos, _, _, _, Val, _)  :-
    user:staticval(Pos, Val), !.                              % Static value of Pos

alphabetamoves(PosList, Pos, Alpha, Beta, GoodPos, Val, Depth)  :-
    Depth =< 0 ->
        user:staticval(Pos, Val)
    ;
        boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth).

boundedbest([Pos | PosList], Alpha, Beta, GoodPos, GoodVal, Depth)  :-
    alphabeta(Pos, Alpha, Beta, _, Val, Depth),
    goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough([], _, _, Pos, Val, Pos, Val, _)  :-  !.    % No other candidate

goodenough(_, Alpha, Beta, Pos, Val, Pos, Val, _)  :-
    user:min_to_move(Pos), Val > Beta, !                   % Maximizer attained upper bound
    ;
    user:max_to_move(Pos), Val < Alpha, !.                 % Minimizer attained lower bound

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth)  :-
    newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),    % Refine bounds
    boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth),
    betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds(Alpha, Beta, Pos, Val, Val, Beta)  :-
    user:min_to_move(Pos), Val > Alpha, !.                 % Maximizer increased lower bound

newbounds(Alpha, Beta, Pos, Val, Alpha, Val)  :-
     user:max_to_move(Pos), Val < Beta, !.                 % Minimizer decreased upper bound

newbounds(Alpha, Beta, _, _, Alpha, Beta).          % Otherwise bounds unchanged

betterof(Pos, Val, _Pos1, Val1, Pos, Val)  :-        % Pos better than Pos1
    user:min_to_move(Pos), Val > Val1, !
    ;
    user:max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).             % Otherwise Pos1 better

% Code below here is our own
board_width(7).
board_height(6).

direction(v(1, 0), horizontal).
direction(v(0, 1), vertical).
direction(v(1, 1), lrdiagonal).
direction(v(-1, 1), rldiagnoal).

choose_base_on_color(Reds, _, red, Reds).
choose_base_on_color(_, Yellows, yellow, Yellows).

search_vector(_, _, _, Required, Required).
search_vector(Coins, c(X, Y), v(Xd, Yd), Required, Ct) :-
    board_width(W), -1 < X, X < W,
    board_height(H), -1 < Y, Y < H,
    member(c(X, Y), Coins),
    NextCt is Ct + 1,
    NextX is X + Xd,
    NextY is Y + Yd,
    search_vector(Coins, c(NextX, NextY), v(Xd, Yd), Required, NextCt).

find_consecutive(Coins, Required, C) :-
    direction(Vec, _),
    search_vector(Coins, C, Vec, Required, 0).

has_won(Reds, Yellows, Color) :-
    choose_base_on_color(Reds, Yellows, Color, Coordinates),
    member(C, Coordinates),
    find_consecutive(Coordinates, 4, C), !.

% Test case
% Note the validity of the board is not checked.
main(Winner):-
    Reds = [ c(1, 1), c(2, 2), c(3, 3), c(4, 4) ],
    Yellows = [ c(3, 4), c(4, 4), c(5, 4), c(6, 4)],
    has_won(Reds, Yellows, Winner).

% ---/// Stuff for the minimax solver ///---

% Let's say Pos is:
% pos(Reds, Yellows, WhoseMove)

% Collects the cost of the game with respect to the incoming pos
% Note that the board state is not checked to be valid.
staticval(pos(RedCounters, YellowCounters, _), WinVal) :-
    has_won(RedCounters, YellowCounters, WhoWon), !,
    choose_base_on_color(-99999, 99999, WhoWon, WinVal), !. % heavy weights for win

staticval(pos(RedCounters, YellowCounters, _), Val) :-
    staticval_player(RedCounters, ValRed),
    staticval_player(YellowCounters, ValYellow),
    Val is ValYellow - ValRed.

% Collects the score of a single player's counters.
staticval_player(PlayersCounters, Val) :-
    findall(1, (
        member(WorkCounter, PlayersCounters),
        find_consecutive(PlayersCounters, 2, WorkCounter)
    ), List),
    length(List, Val).

% Finds how high a token would sit when inserted
get_insert_y(Toks, Col, YVal) :-
    board_height(H),
    get_insert_y(Toks, Col, H, YVal).

get_insert_y([], _, Min, YVal) :-
    YVal is Min - 1.
get_insert_y([c(Col1, _) | Rest], Col, Min, YVal) :-
    Col1 \= Col,
    get_insert_y(Rest, Col, Min, YVal).
get_insert_y([c(Col, Y) | Rest], Col, Min, YVal) :-
    NewMin is min(Y, Min),
    get_insert_y(Rest, Col, NewMin, YVal).

% Computes the new board state should we insert a token
insert_token(pos(Reds, Yellows, WhoseMove), Col, Move) :-
    append(Reds, Yellows, AllToks),
    get_insert_y(AllToks, Col, Y),
    choose_base_on_color(pos([c(Col, Y) | Reds], Yellows, yellow),
                         pos(Reds, [c(Col, Y) | Yellows], red),
                         WhoseMove, Move).

% Find all possible subsequent game states
moves(pos(Reds, Yellows, _), []) :- % if someone won, dont collect moves
    has_won(Reds, Yellows, _), !.
moves(Pos, Moves) :-
    board_width(Width), Col is Width - 1,
    findall(Move, moves(Pos, Move, Col), Moves).

moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
    board_width(W), Col < W, Col > -1,
    %board_height(H), TopSlot is H - 1,
    \+ member(c(Col, 0), Reds),
    \+ member(c(Col, 0), Yellows),
    insert_token(pos(Reds, Yellows, WhoseMove), Col, Move). % space in this col
moves(pos(Reds, Yellows, WhoseMove), Move, Col) :-
    Col > -1, NextCol is Col - 1,
    moves(pos(Reds, Yellows, WhoseMove), Move, NextCol). % search next col

min_to_move(pos(_, _, red)).
max_to_move(pos(_, _, yellow)).

% Just testing
test(GoodPos, Val) :-
    Reds = [c(0, 0), c(0, 1), c(0, 2)],
    Yellows = [],
    Pos = pos(Reds, Yellows, red),
    alphabeta(Pos, -99999, 99999, GoodPos, Val, 6).
        """)

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

    def _update_from_pos_one_colour(self, pylist, colour):
        assert colour in ["red", "yellow"]

        for c in pylist:
            assert c.name == "c"
            (x, y) = c
            self.cols[x][y]["background"] = colour

    def _update_from_pos(self, pos):
        """ update the game state from the result of alphabeta """
        self._update_from_pos_one_colour(pos[0], "red")
        self._update_from_pos_one_colour(pos[1], "yellow")

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
        else:
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

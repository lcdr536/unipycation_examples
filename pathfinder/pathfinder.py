import pydot, Tkinter as tk
import sys, uni

# suppose this came out of the xml parser
nodes = ["a", "b", "c", "d", "e", "f", "g" ]
edges = {
    "a" : ["c"],
    "b" : ["e"],
    "c" : ["b", "d", "f"],
    "d" : ["e"],
    "e" : ["g"],
    "f" : ["g"],
    "g" : ["b"]
}

def edges_to_tuples(edges):
    return [ (x,  y)  for x in edges.keys() for y in edges[x] ]

# GUI code

def gen_graph(edges, nodes, active_edges=[]):
    import pydot
    tuples = edges_to_tuples(edges)
    graph = pydot.Dot(graph_type='digraph', rankdir="lr")

    for n in nodes:
        graph.add_node(pydot.Node(n, shape="none"))

    for (src, dest) in tuples:
        print("%s in %s: %s" % ((src, dest), active_edges, (src, dest) in active_edges))
        edge_colour = "red" if (src, dest) in active_edges else "black"
        print(edge_colour)
        e = pydot.Edge(src, dest, color=edge_colour)
        graph.add_edge(e)

    return graph

# Instantiate Prolog
e = uni.Engine("""
    edge(From, To) :- python:get_edges(From, To).
    path(From, To, MaxLen, Nodes) :-
        path(From, To, MaxLen, Nodes, 1).

    path(Node, Node, _, [Node], _).
    path(From, To, MaxLen, [From | Ahead ], Len) :-
        Len < MaxLen, edge(From, Next),
        Len1 is Len + 1,
        path(Next, To, MaxLen, Ahead, Len1).
""")

# Generate initial graph
graph = gen_graph(edges, nodes, active_edges=[("c", "b")])
graph.set_rankdir("LR")
graph.write("mygraph.gif", format="gif")

# Set up GUI
top = tk.Tk()
top.title("Unipycation: PathFinder")

# entry boxes
col = 1; row = 1
entry_frame = tk.Frame(top)
entry_frame.grid(row=row, column=1)

from_lbl = tk.Label(entry_frame, text="From:")
from_lbl.grid(column=col, row=row)
from_entry = tk.Entry(entry_frame)
from_entry.grid(row=row, column=col+1)
col += 2

#to_lbl = tk.Label(entry_frame, text="To:")
#to_lbl.grid(column=col, row=row)
#to_entry = tk.Entry(entry_frame)
#to_entry.grid(row=row, column=col+1)
#col += 2

max_lbl = tk.Label(entry_frame, text="Max nodes:")
max_lbl.grid(column=col, row=row)
max_spin = tk.Spinbox(entry_frame, from_=0, to=9)
max_spin.grid(row=row, column=col+1)
col += 2


find_paths_closure = lambda : find_paths(e, from_entry, max_spin)

go_button = tk.Button(entry_frame, text="Find Paths",
    command=find_paths_closure)
go_button.grid(row=row, column=col)
col += 2

# initial graph display
col = 1; row += 1
graph_img = tk.PhotoImage(file="mygraph.gif")
graph_lbl = tk.Label(image=graph_img)
graph_lbl.grid(column=1, row=row)

# Prolog helper
def get_edges(src_node):
   return iter(edges[src_node])

def find_paths(engine, from_entry, max_spin):
    print("click")
    paths = e.db.path.iter

    # fetch parameters from gui
    for (to, nodes) in paths(from_entry.get(), None, int(max_spin.get()), None):
        print("To %s via %s" % (to, nodes))

# go
top.mainloop()

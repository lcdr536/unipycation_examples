import pydot, Tkinter as tk
import sys

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

# Generate initial graph
graph = gen_graph(edges, nodes, active_edges=[("c", "b")])
graph.set_rankdir("LR")
graph.write("mygraph.gif", format="gif")

# Set up GUI
top = tk.Tk()
top.title("Unipycation: PathFinder")

graph_img = tk.PhotoImage(file="mygraph.gif")
graph_lbl = tk.Label(image=graph_img)
graph_lbl.grid(column=1, row=1)

# test
lbl = tk.Label(text="This is a test")
lbl.grid(column=1, row=2)

# go
top.mainloop()

import sys
import pprint
import time

import uni

prolog_source = """
countdown(X) :- X > 0, X0 is X - 1, countdown(X0).
countdown(0).
countdown_n_times(N, X) :-
    N > 0, countdown(X), N0 is N - 1, countdown_n_times(N0, X).
countdown_n_times(0, _).
countdown_n_times_python(N, X) :-
    N > 0, python:countdown(X, _), N0 is N - 1, countdown_n_times_python(N0, X).
countdown_n_times_python(0, _).

sum_up_to_n(A, B) :- sum_up_to_n(A, 0, B).
sum_up_to_n(A, Accumulator, Result) :-
    A > 0,
    A0 is A - 1,
    Accumulator1 is Accumulator + A,
    sum_up_to_n(A0, Accumulator1, Result).
sum_up_to_n(0, Result, Result).
sum_up_to_n_many_times(N, X, Expected) :-
    N > 0, sum_up_to_n(X, Res), Res == Expected, N0 is N - 1,
    sum_up_to_n_many_times(N0, X, Expected).
sum_up_to_n_many_times(0, _, _).
sum_up_to_n_many_times_python(N, X, Expected) :-
    N > 0, python:sum_up_to_n(X, Res), Res == Expected, N0 is N - 1,
    sum_up_to_n_many_times_python(N0, X, Expected).
sum_up_to_n_many_times_python(0, _, _).

multiply_and_add(X, Y, Z, Res) :- Res is X + Y * Z.
countdown_using_multiply_and_add(N) :-
    N > 0,
    multiply_and_add(N, 1, -1, N0),
    countdown_using_multiply_and_add(N0).
countdown_using_multiply_and_add(0).

countdown_using_multiply_and_add_in_python(N) :-
    N > 0,
    python:multiply_and_add(N, 1, -1, N0),
    countdown_using_multiply_and_add_in_python(N0).
countdown_using_multiply_and_add_in_python(0).

gen1(X, 1) :- X >= 0.
gen1(X, Y) :- X > 0, X0 is X - 1, gen1(X0, Y).

call_gen1_n_times(Iterations, Count) :-
    Iterations > 0,
    ((gen1(Count, X), X == 1, fail); true),
    Iterations0 is Iterations - 1,
    call_gen1_n_times(Iterations0, Count).
call_gen1_n_times(0, _).

call_gen1_n_times_python(Iterations, Count) :-
    Iterations > 0,
    ((python:gen1(Count, X), X == 1, fail); true),
    Iterations0 is Iterations - 1,
    call_gen1_n_times_python(Iterations0, Count).
call_gen1_n_times_python(0, _).

make_chain(A, B) :- make_chain(A, end, B).
make_chain(X, In, Out) :-
    X > 0,
    X0 is X - 1,
    X2 is X * 2,
    make_chain(X0, pair(X, X2, In), Out).
make_chain(0, In, In).

consume_chain(end, X, X).
consume_chain(pair(X, X2, Next), In, Out) :-
    In1 is In + X2 - X,
    consume_chain(Next, In1, Out).

make_and_consume_chain_n_times(N, X, Expected) :-
    N > 0, make_chain(X, Chain), consume_chain(Chain, 0, Res), Res == Expected,
    N0 is N - 1, make_and_consume_chain_n_times(N0, X, Expected).
make_and_consume_chain_n_times(0, _, _).

make_and_consume_chain_n_times_python(0, _, _).
make_and_consume_chain_n_times_python(N, X, Expected) :-
    N > 0, python:make_chain(X, Chain), consume_chain(Chain, 0, Res), Res == Expected,
    N0 is N - 1, make_and_consume_chain_n_times_python(N0, X, Expected).

make_list(A, B) :- make_list(A, [], B).
make_list(X, In, Out) :-
    X > 0,
    X0 is X - 1,
    make_list(X0, [X|In], Out).
make_list(0, In, In).

consume_list([], X, X).
consume_list([X | Next], In, Out) :-
    In1 is In + X,
    consume_list(Next, In1, Out).

make_and_consume_list_n_times(N, X, Expected) :-
    N > 0, make_list(X, List), consume_list(List, 0, Result), Result == Expected,
    N0 is N - 1, make_and_consume_list_n_times(N0, X, Expected).
make_and_consume_list_n_times(0, _, _).

make_and_consume_list_n_times_python(N, X, Expected) :-
    N > 0, python:make_list(X, PyList), python:uni:build_prolog_list(PyList, List),
    consume_list(List, 0, Result), Result == Expected,
    N0 is N - 1, make_and_consume_list_n_times_python(N0, X, Expected).
make_and_consume_list_n_times_python(0, _, _).

consume_instchain(Inst, X, X) :- Inst:is_terminator(1).
consume_instchain(Inst, In, Out) :-
    Inst:is_terminator(0),
    Inst:get_value(X),
    In1 is In + X,
    Inst:get_next(Next),
    consume_instchain(Next, In1, Out).


make_and_consume_instchain_n_times(N, X, Expected) :-
    N > 0, make_instchain(X, List), consume_instchain(List, 0, Res), Res == Expected,
    N0 is N - 1, make_and_consume_instchain_n_times(N0, X, Expected).
make_and_consume_instchain_n_times(0, _, _).

make_and_consume_instchain_n_times_python(N, X, Expected) :-
    N > 0, python:make_instchain(X, List), consume_instchain(List, 0, Res), Res == Expected,
    N0 is N - 1, make_and_consume_instchain_n_times_python(N0, X, Expected).
make_and_consume_instchain_n_times_python(0, _, _).

make_instchain(A, B) :-
    python:'Terminator'(T),
    make_instchain(A, T, B).

make_instchain(X, In, Out) :-
    X > 0,
    X0 is X - 1,
    python:'Chain'(X, In, Chain),
    make_instchain(X0, Chain, Out).
make_instchain(0, In, In).

"""

e = uni.Engine(prolog_source)

def multiply_and_add(a, b, c):
    return a + b * c

def countdown(n):
    while n > 0:
        n -= 1

def sum_up_to_n(n):
    result = 0
    while n > 0:
        result += n
        n -= 1
    return result

def make_chain(x):
    curr = "end"
    while x >= 0:
        curr = e.terms.pair(x, 2*x, curr)
        x -= 1
    return curr

def consume_chain(chain):
    res = 0
    while chain != "end":
        assert chain.name == "pair"
        val, val2, chain = chain
        res += val2 - val
    return res


class Terminator(object):
    def is_terminator(self):
        return True

class Chain(object):
    def __init__(self, value, next):
        self._value = value
        self._next = next

    def is_terminator(self):
        return False

    def get_value(self):
        return self._value

    def get_next(self):
        return self._next

def make_instchain(x):
    curr = Terminator()
    while x >= 0:
        curr = Chain(x, curr)
        x -= 1
    return curr

def consume_instchain(chain):
    res = 0
    while not chain.is_terminator():
        res += chain.get_value()
        chain = chain.get_next()
    return res

def make_list(x):
    res = []
    while x >= 0:
        res.append(x)
        x -= 1
    return res

def consume_list(l):
    res = 0
    for i in l:
        res += i
    return res

def gen1(x):
    while x >= 0:
        yield 1
        x -= 1

# __________________________________________________________

class BenchMeta(type):
    all_classes = []

    def __new__(cls, name, bases, dct):
        res = type.__new__(cls, name, bases, dct)
        if name != "Bench":
            BenchMeta.all_classes.append(res)
        for key, val in dct.iteritems():
            if hasattr(val, 'func_name'):
                val.func_name = val.func_name + "_" + name # easier to read in trace
        return res

class Bench(object):
    __metaclass__ = BenchMeta

    def __init__(self, args):
        self.iterations = args.iterations
        self.count = args.count
        self.variant = args.variant

    def run(self, repetitions=1):
        results = []
        for i in range(repetitions):
            res = getattr(self, self.variant)(self.iterations, self.count)
            results.append(res)
        return results

    def run_single(self):
        print self.name
        print self.run()[0]

    def prolog(self, iterations, count):
        return "not implemented"

    def pyprolog(self, iterations, count):
        return "not implemented"

    def prologpy(self, iterations, count):
        return "not implemented"

    def python(self, iterations, count):
        return "not implemented"


class SmallFunc(Bench):
    name = "calling a small deterministic function with 3 arguments and 1 result"

    def prolog(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        res = e.db.countdown_using_multiply_and_add(iterations_countdown)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        i = iterations_countdown
        while i > 0:
            i, = e.db.multiply_and_add(i, 1, -1, None)
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        e.db.countdown_using_multiply_and_add_in_python(iterations_countdown)
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        i = iterations_countdown
        while i > 0:
            i = multiply_and_add(i, 1, -1)
        t2 = time.time()
        return t2 - t1

class Loop1Arg0Result(Bench):
    name = "calling a loop with 1 arguments and no results"

    def prolog(self, iterations, count):
        t1 = time.time()
        e.db.countdown_n_times(iterations, count)
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        t1 = time.time()
        for i in range(iterations):
            res = e.db.countdown(count)
            assert res == ()
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        t1 = time.time()
        res = e.db.countdown_n_times_python(iterations, count)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        t1 = time.time()
        for i in range(iterations):
            countdown(count)
        t2 = time.time()
        return t2 - t1

class Loop1Arg1Result(Bench):
    name = "calling a loop with 1 argument and 1 result"

    def prolog(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        e.db.sum_up_to_n_many_times(iterations, count, correct)
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        for i in range(iterations):
            res, = e.db.sum_up_to_n(count, None)
            assert res == correct
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        e.db.sum_up_to_n_many_times_python(iterations, count, correct)
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        for i in range(iterations):
            res = sum_up_to_n(count)
            assert res == correct
        t2 = time.time()
        return t2 - t1

class NondetLoop1Arg1Result(Bench):
    name = "calling a predicate with 1 arguments and 1 result, consuming all of its many solutions"

    def prolog(self, iterations, count):
        t1 = time.time()
        e.db.call_gen1_n_times(iterations, count)
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        t1 = time.time()
        e.db.call_gen1_n_times_python(iterations, count)
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        t1 = time.time()
        for i in range(iterations):
            for i, in e.db.gen1.iter(count, None):
                assert i == 1
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        t1 = time.time()
        for i in range(iterations):
            for i in gen1(count):
                assert i == 1
        t2 = time.time()
        return t2 - t1

class TermConstruction(Bench):
    name = "producing and consuming Prolog terms"

    def prolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        res = e.db.make_and_consume_chain_n_times(iterations, count, correct)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        res = e.db.make_and_consume_chain_n_times_python(iterations, count, correct)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_chain(e.db.make_chain(count, None)[0])
            assert res == correct
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_chain(make_chain(count))
            assert res == correct
        t2 = time.time()
        return t2 - t1

class Lists(Bench):
    name = "producing and consuming lists"

    def prolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        res = e.db.make_and_consume_list_n_times(iterations, count, correct)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        res = e.db.make_and_consume_list_n_times_python(iterations, count, correct)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_list(e.db.make_list(count, None)[0])
            assert res == correct
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_list(make_list(count))
            assert res == correct
        t2 = time.time()
        return t2 - t1

class PythonInstances(Bench):
    name = "producing and consuming Python instances"

    def prolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        e.db.make_and_consume_instchain_n_times(iterations, count, correct)
        t2 = time.time()
        return t2 - t1

    def prologpy(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        res = e.db.make_and_consume_instchain_n_times_python(iterations, count, correct)
        assert res == ()
        t2 = time.time()
        return t2 - t1

    def pyprolog(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_instchain(e.db.make_instchain(count, None)[0])
            assert res == correct
        t2 = time.time()
        return t2 - t1

    def python(self, iterations, count):
        correct = count * (count + 1) // 2
        t1 = time.time()
        for i in range(iterations):
            res = consume_instchain(make_instchain(count))
            assert res == correct
        t2 = time.time()
        return t2 - t1

nice_names = {
    "prolog": "Prolog",
    "python": "Python",
    "pyprolog": "Python->Prolog",
    "prologpy": "Prolog->Python",
}

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Unipycation microbenchmarks')
    parser.add_argument('--iterations', metavar='iterations', type=int, default=100000,
                       help='number of iterations')
    parser.add_argument('--count', metavar='count', type=int, default=1000,
                       help='number of inner iterations')
    parser.add_argument('--repetitions', metavar='', type=int, default=1,
                       help='number of benchmark repetitions')
    parser.add_argument('--variant', metavar='variant', choices=['prolog', 'pyprolog', 'prologpy', 'python', 'all'], default='all',
                       help='which benchmark variant to run')
    parser.add_argument('--filter', metavar='filter', type=str, default='',
                       help='which benchmark variant to run')

    args = parser.parse_args()
    print "starting"

    classes = [cls for cls in BenchMeta.all_classes if args.filter in cls.__name__ or args.filter in cls.name]

    if args.variant == "all":
        all_results = {}
        for cls in classes:
            inst = cls(args)
            print cls.__name__, ":", inst.name
            norm_to = -1
            for variant in ["python", "prolog", "pyprolog", "prologpy"]:
                inst.variant = variant
                results = inst.run(args.repetitions)
                all_results[cls.__name__, variant] = results
                res = results[-1]
                if norm_to == -1:
                    norm_to = res
                else:
                    print nice_names[variant]
                    print "%.3f times slower than pure python" % (res / norm_to, )
            print "__________________________________"
    else:
        for cls in classes:
            cls(args).run_single()
    with file("out.json", "w") as f:
        print >> f, pprint.pformat(all_results)


if __name__ == '__main__':
    main()

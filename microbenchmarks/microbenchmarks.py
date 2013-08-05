import sys
import uni
import time

e = uni.Engine("""
countdown(0).
countdown(X) :- X > 0, X0 is X - 1, countdown(X0).
countdown_n_times(0, _).
countdown_n_times(N, X) :-
    N > 0, countdown(X), N0 is N - 1, countdown_n_times(N0, X).
sum_up_to_n(A, B) :- sum_up_to_n(A, 0, B).
sum_up_to_n(0, Result, Result).
sum_up_to_n(A, Accumulator, Result) :-
    A0 is A - 1,
    Accumulator1 is Accumulator + A,
    sum_up_to_n(A0, Accumulator1, Result).
sum_up_to_n_many_times(0, _, _).
sum_up_to_n_many_times(N, X, Expected) :-
    N > 0, sum_up_to_n(X, Res), Res == Expected, N0 is N - 1,
    sum_up_to_n_many_times(N0, X, Expected).

multiply_and_add(X, Y, Z, Res) :- Res is X + Y * Z.
countdown_using_multiply_and_add(0).
countdown_using_multiply_and_add(N) :-
    N > 0,
    multiply_and_add(N, 1, -1, N0),
    countdown_using_multiply_and_add(N0).
""")

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

class Bench(object):
    def __init__(self, args):
        self.iterations = args.iterations
        self.count = args.count
        self.variant = args.variant

    def run(self):
        return getattr(self, self.variant)(self.iterations, self.count)

    def run_single(self):
        print self.name
        print self.run()

class TinyFunc(Bench):
    name = "calling a tiny function in prolog with 3 arguments and 1 result"

    def prolog(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        e.db.countdown_using_multiply_and_add(iterations_countdown)
        t2 = time.time()
        return t2 - t1

    def both(self, iterations, count):
        iterations_countdown = iterations * count
        t1 = time.time()
        i = iterations_countdown
        while i > 0:
            i, = e.db.multiply_and_add(i, 1, -1, None)
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
    name = "calling a loop in prolog with 1 arguments and no results"
    def prolog(self, iterations, count):
        t1 = time.time()
        e.db.countdown_n_times(iterations, count)
        t2 = time.time()
        return t2 - t1
    def both(self, iterations, count):
        t1 = time.time()
        for i in range(iterations):
            res = e.db.countdown(count)
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
    name = "calling a loop in prolog with 1 argument and 1 result"
    def prolog(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        e.db.sum_up_to_n_many_times(iterations, count, correct)
        t2 = time.time()
        return t2 - t1

    def both(self, iterations, count):
        correct = sum_up_to_n(count)
        t1 = time.time()
        for i in range(iterations):
            res, = e.db.sum_up_to_n(count, None)
            assert res == correct
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

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Unipycation microbenchmarks')
    parser.add_argument('--iterations', metavar='iterations', type=int, default=100000,
                       help='number of iterations')
    parser.add_argument('--count', metavar='count', type=int, default=1000,
                       help='number of inner iterations')
    #parser.add_argument('--repetitions', metavar='', type=int, default=1000,
    #                   help='number of benchmark repetitions')
    parser.add_argument('--variant', metavar='variant', choices=['prolog', 'both', 'python'], default='both',
                       help='which benchmark variant to run')

    args = parser.parse_args()

    for cls in [TinyFunc, Loop1Arg1Result, Loop1Arg0Result]:
        cls(args).run_single()


if __name__ == '__main__':
    main()

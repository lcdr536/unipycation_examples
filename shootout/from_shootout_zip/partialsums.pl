% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Based on D language implementation by David Fladebo
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

main :-
  cmdlNumArg(1, N),
  main(N).

main(N):-
  compute_sums(N), print_sums, drop_sums.

% ------------------------------- %

compute_sums(N) :-
  setvar(sums, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
  compute_sums_(1, N, 1.0).

% ------------- %

compute_sums_(D, N, _) :- D > N, !.

compute_sums_(D, N, ALT) :-
  getvar(sums, [A1, A2, A3, A4, A5, A6, A7, A8, A9]),

  D2 is D * D, D3 is D2 * D, DS is sin(D), DC is cos(D),

  A1N is A1 + (2 / 3.0) ** (D - 1.0),
  A2N is A2 + 1 / sqrt(D),
  A3N is A3 + 1 / (D * (D + 1)),
  A4N is A4 + 1 / (D3 * DS * DS),
  A5N is A5 + 1 / (D3 * DC * DC),
  A6N is A6 + 1 / D,
  A7N is A7 + 1 / (D2),
  A8N is A8 + ALT / D,
  A9N is A9 + ALT / (2 * D - 1),

  setvar(sums, [A1N, A2N, A3N, A4N, A5N, A6N, A7N, A8N, A9N]),
  DN is D + 1, ALTN is -ALT, !, compute_sums_(DN, N, ALTN).

% ------------------------------- %

print_sums :-
  getvar(sums, [A1, A2, A3, A4, A5, A6, A7, A8, A9]),

%%%%z    sformat(S1, '~9f', [A1]), writef('%w\t%w\n', [S1, '(2/3)^k']),
%%%%z    sformat(S2, '~9f', [A2]), writef('%w\t%w\n', [S2, 'k^-0.5']),
%%%%z    sformat(S3, '~9f', [A3]), writef('%w\t%w\n', [S3, '1/k(k+1)']),
%%%%z    sformat(S4, '~9f', [A4]), writef('%w\t%w\n', [S4, 'Flint Hills']),
%%%%z    sformat(S5, '~9f', [A5]), writef('%w\t%w\n', [S5, 'Cookson Hills']),
%%%%z    sformat(S6, '~9f', [A6]), writef('%w\t%w\n', [S6, 'Harmonic']),
%%%%z    sformat(S7, '~9f', [A7]), writef('%w\t%w\n', [S7, 'Riemann Zeta']),
%%%%z    sformat(S8, '~9f', [A8]), writef('%w\t%w\n', [S8, 'Alternating Harmonic']),
%%%%z    sformat(S9, '~9f', [A9]), writef('%w\t%w\n', [S9, 'Gregory']).

    format('~9f\t~w\n', [A1,'(2/3)^k']),
    format('~9f\t~w\n', [A2,'k^-0.5']),
    format('~9f\t~w\n', [A3,'1/k(k+1)']),
    format('~9f\t~w\n', [A4,'Flint Hills']),
    format('~9f\t~w\n', [A5,'Cookson Hills']),
    format('~9f\t~w\n', [A6,'Harmonic']),
    format('~9f\t~w\n', [A7,'Riemann Zeta']),
    format('~9f\t~w\n', [A8,'Alternating Harmonic']),
    format('~9f\t~w\n', [A9,'Gregory']).

% ------------------------------- %

drop_sums :- dropvar(sums).

% ------------------------------- %

%%%z getvar(Id, Value) :- nb_getval(Id, Value).
%%%z setvar(Id, Value) :- nb_setval(Id, Value).
%%%z dropvar(Id) :- nb_delete(Id).
getvar(Id, Value) :- global_heap_get(Id, Value).
setvar(Id, Value) :- global_heap_set(Id, Value).
dropvar(Id) :- true.

% ------------------------------- %
%%%z argument_value(N, Arg) :-
%%%z   current_prolog_flag(argv, Cmdline), append(_, [--|UserArgs], Cmdline),
%%%z   Nth is N - 1, nth0(Nth, UserArgs, Arg).

%%%z cmdlNumArg(Nth, N) :-
%%%z   argument_value(Nth, Arg), catch(atom_number(Arg, N), _, fail) ; halt(1).

argument_value(N, Arg) :-
  get_main_args(Cmdline), 
  append(_, [--|UserArgs], Cmdline),
  Nth is N - 1, nth0(Nth, UserArgs, Arg).

cmdlNumArg(Nth, N) :-
  argument_value(Nth, Arg), 
  catch(atom_number(Arg, N), _, fail) ; halt(1).

atom_number(Arg,N):-
   atom_codes(Arg,Codes),
   number_codes(N,Codes).

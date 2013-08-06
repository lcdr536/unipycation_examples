% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

main :-
  cmdlNumArg(1, N),
  writeln(main(N)),
  main(N).

main(N):-
  approximate(N, R),
  format('~9f~n', [R]).

% ------------------------------- %

approximate(N, R) :-
  make_array(app_u, N, 1.0, U), make_array(app_v, N, 0.0, V),

  setvar(counter, 1),
  repeat,
    getvar(counter, I), I1 is I + 1, setvar(counter, I1),
    mulAtAv(N, U, V),
    mulAtAv(N, V, U),
  I >= 10,
  dropvar(counter),

  vbv_loop(N, U, V, VbV), vv_loop(N, V, V, Vv),

  drop_array(app_u), drop_array(app_v),

  Vi is VbV / Vv, R is sqrt(Vi).

% ------------- %

vbv_loop(N, U, V, VbV) :- vbv_loop_(N, U, V, 0.0, VbV).

vbv_loop_(0, _, _, VAcc, VAcc) :- !.

vbv_loop_(N, U, V, VAcc, VbV) :-
  get_arg(N, U, UValue), get_arg(N, V, VValue),
  VAcc1 is VAcc + UValue * VValue,
  N1 is N - 1, !, vbv_loop_(N1, U, V, VAcc1, VbV).

% ------------- %

vv_loop(N, U, V, Vv) :- vv_loop_(N, U, V, 0.0, Vv).

vv_loop_(0, _, _, VAcc, VAcc) :- !.

vv_loop_(N, U, V, VAcc, Vv) :-
  get_arg(N, V, VValue),
  VAcc1 is VAcc + VValue * VValue,
  N1 is N - 1, !, vv_loop_(N1, U, V, VAcc1, Vv).

% ------------------------------- %

a(I, J, AResult) :-
  Ia is I - 1, Ja is J - 1,
  AResult is 1.0 / ((Ia + Ja) * (Ia + Ja + 1.0) / 2.0 + Ia + 1.0).

% ------------------------------- %

mulAv(N, V, Av) :-  mulAv_(N, N, N, V, Av).

% ------------- %

mulAv_(0, _, _, _, _) :- !.

mulAv_(I, J, N, V, Av) :-
  set_arg(I, Av, 0.0),
  mulAvJ_(I, J, N, V, Av),
  I1 is I - 1, !, mulAv_(I1, J, N, V, Av).

mulAvJ_(_, 0, _, _, _) :- !.

mulAvJ_(I, J, N, V, Av) :-
  get_arg(I, Av, AvValue), get_arg(J, V, VValue), a(I, J, AResult),
  AvNew is AvValue + AResult * VValue,
  set_arg(I, Av, AvNew),
  J1 is J - 1, !, mulAvJ_(I, J1, N, V, Av).

% ------------------------------- %

mulAtV(N, V, Atv) :-  mulAtV_(N, N, N, V, Atv).

% ------------- %

mulAtV_(0, _, _, _, _) :- !.

mulAtV_(I, J, N, V, Atv) :-
  set_arg(I, Atv, 0.0),
  mulAtVJ_(I, J, N, V, Atv),
  I1 is I - 1, !, mulAtV_(I1, J, N, V, Atv).

mulAtVJ_(_, 0, _, _, _) :- !.

mulAtVJ_(I, J, N, V, Atv) :-
  get_arg(I, Atv, AtvValue), get_arg(J, V, VValue), a(J, I, AResult),
  AtvNew is AtvValue + AResult * VValue,
  set_arg(I, Atv, AtvNew),
  J1 is J - 1, !, mulAtVJ_(I, J1, N, V, Atv).

% ------------------------------- %

mulAtAv(N, V, AtAv) :-
  make_array(mul_u, N, 0.0, U),
  mulAv(N, V, U), mulAtV(N, U, AtAv),
  drop_array(mul_u).

% ------------------------------- %

make_array(Name, N, V, Array) :-
  functor(Array, Name, N),
  fill_array(N, V, Array).

% ------------- %

fill_array(0, _, _) :- !.

fill_array(N, V, Array) :-
  nb_setarg(N, Array, V), N1 is N - 1, !,
  fill_array(N1, V, Array).

% ------------- %

drop_array(Name) :- nb_delete(Name).

% ------------- %

set_arg(N, Array, V) :- nb_setarg(N, Array, V).
get_arg(N, Array, V) :- arg(N, Array, V).


% ------------- %

%%%z getvar(Id, Value) :- nb_getval(Id, Value).
%%%z setvar(Id, Value) :- nb_setval(Id, Value).
%%%z dropvar(Id) :- nb_delete(Id).
getvar(Id, Value) :- global_get(Id, Value).
setvar(Id, Value) :- global_set(Id, Value).
dropvar(Id) :- global_del(Id).
nb_setarg(I,A,V):-setarg(I,A,V).
nb_delete(Id):-true.

% ------------------------------- %

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



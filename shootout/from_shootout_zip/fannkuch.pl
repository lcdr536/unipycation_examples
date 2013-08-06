% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

main :-
  cmdlNumArg(1, N),
  main(N).

main(N):-
  init_fannkuch,

  f_permutations(N, MaxFlips),
  format('Pfannkuchen(~d) = ~d~n', [N, MaxFlips]),

  drop_fannkuch.

% ------------------------------- %

init_fannkuch :- setvar(perm_N, 0), setvar(max_flips, 0).

% ------------- %

drop_fannkuch :- dropvar(perm_N), dropvar(max_flips).

% ------------------------------- %

f_permutations(N, MaxFlips) :-
  numlist(1, N, L),
  f_permutations_(L, N, 0),
  getvar(max_flips, MaxFlips).

% ------------- %

f_permutations_(L, N, I) :-
  (I < N ->
    (N =:= 1 ->
      !, processPerm(L)
    ;
      N1 is N - 1,
      f_permutations_(L, N1, 0),
      take_drop(L, N, Lt, Ld),
      rotateLeft(Lt, LtRL),
      reverse(LtRL, LtRLR), append(LtRLR, Ld, La), Ii is I + 1,
      !, f_permutations_(La, N, Ii))
  ;
    !, true).

% ------------------------------- %

flips(L, Flips) :- flips_(L, 0, Flips).

flips_([1|_], Fla, Fla) :- !.

flips_([N|T], Fla, Flips) :-
  take_drop([N|T], N, Lt, Ld), append(Lt, Ld, La),
  Fla1 is Fla + 1, !, flips_(La, Fla1, Flips).

% ------------------------------- %

rotateLeft([], []).

rotateLeft([H|T], RL) :- append(T, [H], RL).

% ------------------------------- %

%%%z printPerm(L) :- concat_atom(L, NA), format('~w~n', [NA]).
printPerm(L) :- format('~w~n', [L]).

% ------------------------------- %

processPerm(L) :-
  getvar(max_flips, MaxFlips), getvar(perm_N, PermN),
  flips(L, Flips),
  (Flips > MaxFlips ->
    setvar(max_flips, Flips)
  ;
    true),
  (PermN < 30 ->
    printPerm(L),
    PermN1 is PermN + 1,
    setvar(perm_N, PermN1)
  ;
    true).

% ------------------------------- %

take_drop(L, N, Taken, Rest) :- take_drop_(L, N, 0, [], Taken, Rest).

%
% 'take' list returned in reverse order. If wanting it in order, use:
%
% take_drop_(L, N, N, Ta, Taken, L) :- !, reverse(Ta, Taken).
%

take_drop_(L, N, N, Ta, Ta, L) :- !.

take_drop_([H|T], N, Nc, Ta, Taken, Rest) :-
  Nc1 is Nc + 1, !, take_drop_(T, N, Nc1, [H|Ta], Taken, Rest).

% ------------------------------- %

%%%z getvar(Id, Value) :- nb_getval(Id, Value).
%%%z setvar(Id, Value) :- nb_setval(Id, Value).
%%%z dropvar(Id) :- nb_delete(Id).
getvar(Id, Value) :- global_get(Id, Value).
setvar(Id, Value) :- global_set(Id, Value).
dropvar(Id) :- global_del(Id).

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


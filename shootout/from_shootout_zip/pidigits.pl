% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

%main :-
%  cmdlNumArg(1, N),
%    main(N).

main(N):-
  pidigits(N).

% ------------------------------- %

pidigits(N) :- pidigits_(1, [1, 0, 0, 1], N, 0, 0).

% ------------- %

pidigits_(K, Z, N, Row, Col) :-
  (N > 0 ->
    next(Z, Y), safe(Z, Y, IsSafe),
    (IsSafe ->
      prod(Z, Y, RL), N1 is N - 1,
      (Col =:= 10 ->
        %Cf is 1, Rf is 10 + Row, format('\t:~w\n~w', [Rf, Y])
        Cf is 1, Rf is 10 + Row, write('\t:'), write(Rf), nl, write(Y)
      ;
        %Cf is 1 + Col, Rf is Row, format('~w', [Y])),
	Cf is 1 + Col, Rf is Row, write(Y)),
	!, pidigits_(K, RL, N1, Rf, Cf)
    ;
      cons(Z, K, RL), K1 is K + 1,
      !, pidigits_(K1, RL, N, Row, Col))
  ;
    %NS is 10 - Col, tab(NS), RC is Row + Col, format('\t:~w\n', [RC])).
    NS is 10 - Col, tab(NS), RC is Row + Col, write('\t:'), write(RC), nl).

tab(0).
tab(X) :- write(' '), NextX is X - 1, tab(NextX).

% ------------- %

next([Q, R, S, T], RV) :- RV is (3 * Q + R) // (3 * S + T).

safe([Q, R, S, T], N, RV) :-
  V is ((4 * Q + R) // (4 * S + T)), (V =:= N -> RV = true ; RV = fail).

comp([Q1, R1, S1, T1], [Q2, R2, S2, T2], [QO, RO, SO, TO]) :-
  QO is Q1 * Q2 + R1 * S2, RO is Q1 * R2 + R1 * T2,
  SO is S1 * Q2 + T1 * S2, TO is S1 * R2 + T1 * T2.

prod(Z, N, RL) :- A2 is -10 * N, comp([10, A2, 0, 1], Z, RL).

cons(Z, K, RL) :- A2 is 4 * K + 2, A4 is 2 * K + 1, comp(Z, [K, A2, 0, A4], RL).

% ------------------------------- %
%%%z argument_value(N, Arg) :-
%%%z   current_prolog_flag(argv, Cmdline), append(_, [--|UserArgs], Cmdline),
%%%z   Nth is N - 1, nth0(Nth, UserArgs, Arg).

%%%z cmdlNumArg(Nth, N) :-
%%%z   argument_value(Nth, Arg), catch(atom_number(Arg, N), _, fail) ; halt(1).

%argument_value(N, Arg) :-
%  get_main_args(Cmdline), 
%  append(_, [--|UserArgs], Cmdline),
%  Nth is N - 1, nth0(Nth, UserArgs, Arg).

%cmdlNumArg(Nth, N) :-
%  argument_value(Nth, Arg), 
%  catch(atom_number(Arg, N), _, fail) ; halt(1).

%atom_number(Arg,N):-
%   atom_codes(Arg,Codes),
%   number_codes(N,Codes).

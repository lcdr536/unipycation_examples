% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Assumes execution using the following command-line usage:
%
% pl -q -g main -t halt -s SOURCENAME -- USERARG1 ... < in > out
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

main(Height) :-
	%argument_value(1, Height),
	nb_setval(byteout, 0), nb_setval(bitnumber, 0),
	format('P4~N~d ~d~N',[Height, Height]),
	Limit is Height - 1,
	ignore((between(0, Limit, Y),
	between(0, Limit, X),
	point(X, Y, Height, Height),
	fail)),
	halt.

point(X, Y, Height, Width) :-
	nb_getval(byteout, Out0),
	( mandel(Height, Width, Y, X, 50) ->
	Out1 is Out0 << 1 + 1
	; Out1 is Out0 << 1
	),
	nb_getval(bitnumber, Bit0),
	succ(Bit0, Bit1),
	nb_setval(bitnumber, Bit1),
	( Bit1 =:= 8 -> output(Out1)
	; Width - 1 =:= X ->
	Out2 is Out1 * (1 << (8 - Width mod 8)),
	output(Out2)
	; nb_setval(byteout, Out1)
	).

mandel(Height, Width, Y, X, Repetitions) :-
	Cr is ( X << 1 / Width - 1.5),
	Ci is ( Y << 1 / Height - 1.0),
	mandel_(Repetitions, Cr, Ci, 0.0, 0.0).

mandel_(0, _, _, _, _) :- !.
mandel_(N, Cr, Ci, Zr, Zi) :-
	Zr1 is Zr*Zr - Zi*Zi + Cr,
	Zi1 is 2 * Zr * Zi + Ci,
	Zr1*Zr1 + Zi1*Zi1 =< 4,
	succ(N1, N),
	mandel_(N1, Cr, Ci, Zr1, Zi1).

output(Byte) :-
	put_byte(Byte),
	nb_setval(bitnumber, 0), nb_setval(byteout, 0).

%argument_value(Nth, N) :-
%	( current_prolog_flag(argv, Cmdline),
%	append(_, [--|UserArgs], Cmdline),
%	nth1(Nth, UserArgs, Arg),
%	catch(atom_number(Arg, N), _, fail) -> true
%	; halt(1)
%	).

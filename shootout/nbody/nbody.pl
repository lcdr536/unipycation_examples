% ----------------------------------------------------------------------
% The Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Assumes execution using the following command-line usage:
%
% pl -q -g main -t halt -s SOURCENAME -- USERARG1 ... < in > out
%
% Contributed by Anthony Borla
% Improved by Tom Schrijvers
% Improved by Bart Demoen
%
% ----------------------------------------------------------------------
main :-
	cmdlNumArg(1, N),
	main(N).

main(N) :-
	make_bodies(Bodies),
	offset_momentum(Bodies,NewBodies),
	energy(NewBodies, EnergyStart),
	advance(NewBodies, N, 0.01, FinalBodies),
	energy(FinalBodies, EnergyAfter),

	% format('~9f~N~9f~N', [EnergyStart, EnergyAfter]),
	write([EnergyStart, EnergyAfter]), nl.

% ------------------------------- %

offset_momentum(Bodies,NewBs) :-
	offset(Bodies,0.0,0.0,0.0,PX,PY,PZ),
	solar_mass(SOLAR_MASS),
	planet(sun, body(X, Y, Z, _, _, _, Mass)),
	VX1 is -(PX / SOLAR_MASS),
	VY1 is -(PY / SOLAR_MASS),
	VZ1 is -(PZ / SOLAR_MASS),
	[body(X, Y, Z, VX1, VY1, VZ1, Mass)|Bodies] = NewBs.

	offset([],PX,PY,PZ,PX,PY,PZ).

offset([Body|Bodies],PX,PY,PZ,NPX,NPY,NPZ) :-
	Body = body(_, _, _, VX, VY, VZ, Mass),
	PX1 is PX + VX * Mass,
	PY1 is PY + VY * Mass,
	PZ1 is PZ + VZ * Mass,
	offset(Bodies,PX1,PY1,PZ1,NPX,NPY,NPZ).

% ------------------------------- %

energy(Bodies, Energy) :-
	energy(Bodies,0.0,Energy).

energy([],C,C).
energy([Body|Bodies],C,NC) :-
	Body = body(X, Y, Z, VX, VY, VZ, Mass),
	C1 is C + 0.5 * Mass * (VX * VX + VY * VY + VZ * VZ),
	energy_dist(Bodies,X,Y,Z,Mass,C1,C2),
	energy(Bodies,C2,NC).

energy_dist([],_,_,_,_,C,C).
energy_dist([Body|Bodies],X,Y,Z,Mass,C,NC) :-
	Body = body(XT, YT, ZT, _, _, _, MassT),
	DX is X - XT, DY is Y - YT, DZ is Z - ZT,
	DISTANCE is sqrt(DX * DX + DY * DY + DZ * DZ),
	C1 is C - (Mass * MassT) / DISTANCE,
	energy_dist(Bodies,X,Y,Z,Mass,C1,NC).

% ------------------------------- %

advance(Bodies, Repetitions, DT, FinalBodies) :-
	(Repetitions == 0 ->
	FinalBodies = Bodies
	;
	treatallpairs(Bodies,DT,Bodies1),
	updateeach(Bodies1,DT,Bodies2),
	Repetitions1 is Repetitions - 1,
	advance(Bodies2, Repetitions1, DT, FinalBodies)
	).

treatallpairs(BodiesIn,DT,BodiesOut) :-
	BodiesIn = [B|Bs],
	(Bs == [] ->
	BodiesOut = BodiesIn
	;
	BodiesIn = [B|Bs],
	treatallpairs1(Bs,B,DT,NewB,NewBs),
	BodiesOut = [NewB|RestOut],
	treatallpairs(NewBs,DT,RestOut)
	).

treatallpairs1([],B,_,B,[]).
treatallpairs1([ET|RET],E,DT,NewB,NewBs) :-
	E = body(X, Y, Z, VX, VY, VZ, Mass),
	ET = body(XT, YT, ZT, VXT, VYT, VZT, MassT),

	DX is X - XT, DY is Y - YT, DZ is Z - ZT,
	DISTANCE is sqrt(DX * DX + DY * DY + DZ * DZ),
	Mag is DT / (DISTANCE * DISTANCE * DISTANCE),

	VX1 is VX - DX * MassT * Mag,
	VY1 is VY - DY * MassT * Mag,
	VZ1 is VZ - DZ * MassT * Mag,

	VXT1 is VXT + DX * Mass * Mag,
	VYT1 is VYT + DY * Mass * Mag,
	VZT1 is VZT + DZ * Mass * Mag,

	NewE = body(X, Y, Z, VX1, VY1, VZ1, Mass),
	NewET = body(XT, YT, ZT, VXT1, VYT1, VZT1, MassT),
	NewBs = [NewET|RestNewBs],
	treatallpairs1(RET,NewE,DT,NewB,RestNewBs).

updateeach([],_,[]).
updateeach([body(X, Y, Z, VX, VY, VZ, Mass)|R],DT, [body(X1, Y1, Z1, VX, VY, VZ, Mass)|S]) :-
	X1 is X + DT * VX, Y1 is Y + DT * VY, Z1 is Z + DT * VZ,
	updateeach(R,DT,S).


% ------------------------------- %

make_bodies(Bodies) :-
	findall(V, (planet(Body,V), Body \== sun), Bodies).

%solar_mass(3.9478417604357432000e+01).
solar_mass(39.478417604357432000).

planet(sun, body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS)) :-
	solar_mass(SOLAR_MASS).
%planet(jupiter, body(4.84143144246472090e+00, -1.16032004402742839e+00,
%-1.03622044471123109e-01, 6.06326392995832020e-01,
%2.811986844916260200e+00, -2.5218361659887636e-02,
%3.7693674870389486e-02)).
planet(jupiter, body(4.84143144246472090, -1.16032004402742839,
-0.103622044471123109, 0.606326392995832020,
2.811986844916260200, -0.025218361659887636,
0.037693674870389486)).
%planet(saturn,	body(8.34336671824457987e+00, 4.12479856412430479e+00,
%-4.03523417114321381e-01, -1.010774346178792400e+00,
%1.825662371230411900e+00, 8.415761376584154e-03,
%1.1286326131968767e-02)).
planet(saturn,	body(8.34336671824457987, 4.12479856412430479,
-0.403523417114321381, -1.010774346178792400,
1.825662371230411900, 0.008415761376584154,
0.011286326131968767)).
%planet(uranus,	body(1.28943695621391310e+01, -1.51111514016986312e+01,
%-2.23307578892655734e-01, 1.082791006441535600e+00,
%8.68713018169607890e-01, -1.0832637401363636e-02,
%1.723724057059711e-03)).
planet(uranus,	body(12.8943695621391310, -15.1111514016986312,
-0.223307578892655734, 1.082791006441535600,
0.868713018169607890, -0.010832637401363636,
0.001723724057059711)).
%planet(neptune,	body(1.53796971148509165e+01, -2.59193146099879641e+01,
%1.79258772950371181e-01, 9.79090732243897980e-01,
%5.94698998647676060e-01, -3.4755955504078104e-02,
%2.033686869924631e-03)).
planet(neptune,	body(15.3796971148509165, -25.9193146099879641,
0.179258772950371181, 0.979090732243897980,
0.594698998647676060, -0.034755955504078104,
0.002033686869924631)).

% ------------------------------- %

argument_value(N, Arg) :-
	current_prolog_flag(argv, Cmdline), append(_, [--|UserArgs], Cmdline),
	Nth is N - 1, nth0(Nth, UserArgs, Arg).

cmdlNumArg(Nth, N) :-
	argument_value(Nth, Arg), catch(atom_number(Arg, N), _, fail) ; halt(1).

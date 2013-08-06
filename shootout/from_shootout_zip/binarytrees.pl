% ----------------------------------------------------------------------
% The Great Computer Language Shootout
% http://shootout.alioth.debian.org/
%
% Contributed by Anthony Borla
% ----------------------------------------------------------------------

%main :-
%  cmdlNumArg(1, N),
%
%  main(N).

main(N) :-
  MIN_DEPTH is 4, set_limits(N, MIN_DEPTH, MAX_DEPTH, STRETCH_DEPTH),

  bottom_up_tree(0, STRETCH_DEPTH, ST),

  check_tree(ST, ITS),
  %format('stretch tree of depth ~w\t check: ~w~n', [STRETCH_DEPTH, ITS]),
  write(stretch_tree_of_depth), nl,
  write(STRETCH_DEPTH), nl,
  write(check), nl,
  write(ITS), nl,

  bottom_up_tree(0, MAX_DEPTH, LLT),
  descend_trees(MIN_DEPTH, MIN_DEPTH, MAX_DEPTH),

  check_tree(LLT, ITL),
  %format('long lived tree of depth ~w\t check: ~w~n', [MAX_DEPTH, ITL]).
  write(long_lived_tree_of_depth), nl,
  write(MAX_DEPTH), nl,
  write(check), nl,
  write(ITL), nl.

% ------------------------------- %

set_limits(N, MinDepth, MaxDepth, StretchDepth) :-
  MinDepth1 is MinDepth + 2,
  (MinDepth1 > N -> MaxDepth is MinDepth1 ; MaxDepth is N),
  StretchDepth is MaxDepth + 1.

% ------------------------------- %

descend_trees(CurrentDepth, MinDepth, MaxDepth) :-
  (CurrentDepth =< MaxDepth ->
    %N is integer(2 ** (MaxDepth - CurrentDepth + MinDepth)), Iterations is 2 * N,
    N is floor(2 ** (MaxDepth - CurrentDepth + MinDepth)), Iterations is 2 * N,
    sum_trees(N, CurrentDepth, 0, Sum),
    %format('~w\t trees of depth ~w\t check: ~w~n', [Iterations, CurrentDepth, Sum]),
    write(Iterations), nl,
    write(trees_of_depth), nl,
    write(CurrentDepth), nl,
    write(check), nl,
    write(Sum), nl,

    NewDepth is CurrentDepth + 2, !, descend_trees(NewDepth, MinDepth, MaxDepth)
  ;
    true).

% ------------- %

sum_trees(N, _, AccSum, AccSum) :- N=:=0,!.

sum_trees(N, CurrentDepth, AccSum, Sum) :-
  bottom_up_tree(N, CurrentDepth, TreeLeft),
  Nneg is -1 * N, bottom_up_tree(Nneg, CurrentDepth, TreeRight),
  check_tree(TreeLeft, ItemLeft), check_tree(TreeRight, ItemRight),
  AccSum1 is AccSum + ItemLeft + ItemRight,
  N1 is N - 1, !, sum_trees(N1, CurrentDepth, AccSum1, Sum).

% ------------------------------- %

make_tree(Item, Left, Right, tree(Item, Left, Right)).

% ------------- %

bottom_up_tree(Item, 0, tree(Item, nil, nil)) :- !.

bottom_up_tree(Item, Depth, Tree) :-
  ItemLeft is 2 * Item - 1, DepthLeft is Depth - 1, bottom_up_tree(ItemLeft, DepthLeft, TreeLeft),
  ItemRight is 2 * Item, DepthRight is Depth - 1, bottom_up_tree(ItemRight, DepthRight, TreeRight),
  make_tree(Item, TreeLeft, TreeRight, Tree).

% ------------- %

check_tree(tree(Item, nil, _), Item) :- !.

check_tree(tree(Item, Left, Right), ItemNew) :-
  check_tree(Left, ItemLeft),
  check_tree(Right, ItemRight),
  ItemNew is Item + ItemLeft - ItemRight.

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

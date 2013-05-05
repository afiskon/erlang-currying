Currying in Erlang
-----------------
Usage:

    1> F0 = curried:make(fun(A,B,C,D,E,F) -> [A,B,C,D,E,F] end).
    {curried_function,#Fun<erl_eval.17.17052888>,6,[],[]}
    2> F1 = curried:apply(F0, [1,2,3]).
    {curried_function,#Fun<erl_eval.17.17052888>,3,[3,2,1],[]}
    3> curried:arity(F1).                                       
    3
    4> F2 = curried:rapply(F1, [5,6]).
    {curried_function,#Fun<erl_eval.17.17052888>,1,[3,2,1],[5,6]}
    5> curried:apply(F2, [4]).
    [1,2,3,4,5,6]

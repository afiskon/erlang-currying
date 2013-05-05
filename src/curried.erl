-module(curried).

-export([
        make/1,
        apply/2,
        rapply/2,
        arity/1
    ]).

-record(curried_function, {
        function :: function() | { atom(), atom(), non_neg_integer() },
        arity :: non_neg_integer(),
        left_args = [] :: [ _ ],
        right_args = [] :: [ _ ]
    }).
-type apply_result() :: #curried_function{} | _ | no_return().

-spec make(function() | { atom(), atom(), non_neg_integer() }) -> #curried_function{}.
make(Fun)
        when is_function(Fun), not is_function(Fun, 0) ->
    {arity, Arity} = erlang:fun_info(Fun, arity),
    #curried_function {
        function = Fun,
        arity = Arity
    };

make({Module, Function, Arity} = MFA)
        when is_atom(Module), is_atom(Function), is_integer(Arity), Arity > 0 ->
    #curried_function {
        function = MFA,
        arity = Arity
    }.

-spec apply(#curried_function{}, [_]) -> apply_result().
apply(CurriedFunction, ArgList) ->
    apply_priv(left, CurriedFunction, ArgList).

-spec rapply(#curried_function{}, [_]) -> apply_result().
rapply(CurriedFunction, ArgList) ->
    apply_priv(right, CurriedFunction, lists:reverse(ArgList)).

-spec arity(#curried_function{}) -> non_neg_integer().
arity(#curried_function{ arity = Arity }) ->
    Arity.

%% Internal Functions

-spec apply_priv(left | right, #curried_function{}, [_]) -> apply_result().
apply_priv(Side, #curried_function{} = CurriedFunction, ArgList)
        when is_list(ArgList) ->
    NewCurriedFunction = 
        lists:foldl(
            fun(Item, Acc) -> apply_one_arg(Side, Acc, Item) end,
            CurriedFunction,
            ArgList),
    apply_if_arity_is_zero(NewCurriedFunction).

-spec apply_if_arity_is_zero(#curried_function{}) -> apply_result().
apply_if_arity_is_zero(#curried_function{ function = {M,F,A}, arity = 0 } = CurriedFunction) ->
    erlang:apply(fun M:F/A, make_arg_list(CurriedFunction));
                
apply_if_arity_is_zero(#curried_function{ function = Fun, arity = 0 } = CurriedFunction) ->
    erlang:apply(Fun, make_arg_list(CurriedFunction));

apply_if_arity_is_zero(#curried_function{} = CurriedFunction) ->
    CurriedFunction.

-spec apply_one_arg(left | right, #curried_function{}, _) -> apply_result().
apply_one_arg(_, #curried_function{ function = Fun, arity = Arity } = CurriedFunction, Arg)
        when Arity == 0 ->
    throw({bad_arity, { Fun, make_arg_list(CurriedFunction), Arg }});

apply_one_arg(left, #curried_function{ left_args = LeftArgs, arity = Arity } = CurriedFunction, Arg) ->
    CurriedFunction#curried_function{
        left_args = [Arg | LeftArgs],
        arity = Arity - 1
    };

apply_one_arg(right, #curried_function{ right_args = RightArgs, arity = Arity } = CurriedFunction, Arg) ->
    CurriedFunction#curried_function{
        right_args = [Arg | RightArgs],
        arity = Arity - 1
    }.

-spec make_arg_list(#curried_function{}) -> [_].
make_arg_list(#curried_function{ left_args = LeftArgs, right_args = RightArgs }) ->
    lists:reverse(LeftArgs) ++ RightArgs.

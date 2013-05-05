-module(basic_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
    [
        fun_test,
        mfa_test,
        fun_arity_test,
        mfa_arity_test,
        fun_arg_order_test,
        mfa_arg_order_test,
        bad_function_test,
        apply_bad_first_argument_test,
        apply_bad_second_argument_test,
        bad_arity_test
    ].

fun_test(_) ->
    Fun = curried:make(fun(X, Y) -> X - Y end),
    Result = curried:apply(Fun, [123, 23]),
    ?assertEqual(100, Result).

mfa_test(_) ->
    Fun = curried:make({erlang, length, 1}),
    List = [10, 11, 12],
    Result = curried:apply(Fun, [List]),
    ?assertEqual(3, Result).

fun_arity_test(_) ->
    run_arity_test(get_test_fun()).

mfa_arity_test(_) ->
    run_arity_test(get_test_mfa()).

fun_arg_order_test(_) ->
    run_arg_order_test(get_test_fun()).

mfa_arg_order_test(_) ->
    run_arg_order_test(get_test_mfa()).

bad_function_test(_) ->
    ?assertError(function_clause, curried:make(bebebe)).

apply_bad_first_argument_test(_) ->
    ?assertError(function_clause, curried:apply(bebebe, [1,2,3])).

apply_bad_second_argument_test(_) ->
    Fun = curried:make(fun(X, Y) -> X + Y end),
    ?assertError(function_clause, curried:apply(Fun, bebebe)).

bad_arity_test(_) ->
    Fun = curried:make(fun(X, Y) -> X + Y end),
    ?assertThrow({bad_arity, _}, curried:apply(Fun, [1,2,3])).

% Internal Functions

run_arity_test(TestFun) ->
    F0 = curried:make(TestFun),
    ?assertEqual(7, curried:arity(F0)),
    F1 = curried:apply(F0, [1]),
    ?assertEqual(6, curried:arity(F1)),
    F2 = curried:apply(F1, [2,3]),
    ?assertEqual(4, curried:arity(F2)),
    F3 = curried:rapply(F2, [7]),
    ?assertEqual(3, curried:arity(F3)),
    F4 = curried:rapply(F3, [5,6]),
    ?assertEqual(1, curried:arity(F4)).

run_arg_order_test(TestFun) ->
    F0 = curried:make(TestFun),
    F1 = curried:apply(F0, [1]),
    F2 = curried:apply(F1, [2,3]),
    F3 = curried:rapply(F2, [7]),
    F4 = curried:rapply(F3, [5,6]),
    Result = curried:apply(F4, [4]),
    ?assertEqual([1,2,3,4,5,6,7], Result).

get_test_fun() ->
    fun ?MODULE:test_function/7.

get_test_mfa() ->
    { ?MODULE, test_function, 7 }.

test_function(A, B, C, D, E, F, G) ->
    [A, B, C, D, E, F, G].

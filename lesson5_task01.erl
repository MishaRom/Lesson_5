-module(lesson5_task01).
-export([run/0]).

% Кількість операцій для тестування
-define(TEST_SIZE, 10000).

run() ->
    io:format("~nRunning KV Store Benchmark...~n"),

    %% ETS Benchmark
    {TimeAddETS, TimeUpdateETS, TimeDeleteETS, TimeReadETS} = benchmark_ets(),

    %% Maps Benchmark
    {TimeAddMaps, TimeUpdateMaps, TimeDeleteMaps, TimeReadMaps} = benchmark_maps(),

    %% Proplists Benchmark
    {TimeAddProplists, TimeUpdateProplists, TimeDeleteProplists, TimeReadProplists} = benchmark_proplists(),

    %% Print Results
    io:format("~nComparison Table:\n"),
    io:format("| Mechanism  | Add Time (us) | Update Time (us) | Delete Time (us) | Read Time (us) |\n"),
    io:format("|------------|---------------|------------------|------------------|----------------|\n"),
    io:format("| ETS        | ~10w | ~16w | ~16w | ~16w |\n",
              [TimeAddETS, TimeUpdateETS, TimeDeleteETS, TimeReadETS]),
    io:format("| Maps       | ~10w | ~16w | ~16w | ~16w |\n",
              [TimeAddMaps, TimeUpdateMaps, TimeDeleteMaps, TimeReadMaps]),
    io:format("| Proplists  | ~10w | ~16w | ~16w | ~16w |\n",
              [TimeAddProplists, TimeUpdateProplists, TimeDeleteProplists, TimeReadProplists]),
    ok.

%% ETS Benchmark
benchmark_ets() ->
    Tab = ets:new(test_table, [set, public]),

    %% Add Elements
    {AddTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> ets:insert(Tab, {I, I}) end, lists:seq(1, ?TEST_SIZE))
    end),

    %% Update Elements
    {UpdateTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> ets:insert(Tab, {I, I + 1}) end, lists:seq(1, ?TEST_SIZE))
    end),

    %% Delete Elements
    {DeleteTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> ets:delete(Tab, I) end, lists:seq(1, ?TEST_SIZE))
    end),

    %% Read Elements
    {ReadTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> _ = ets:lookup(Tab, I) end, lists:seq(1, ?TEST_SIZE))
    end),

    ets:delete(Tab),
    {AddTime, UpdateTime, DeleteTime, ReadTime}.

%% Maps Benchmark
benchmark_maps() ->
    Map0 = #{},

    %% Add Elements
    {AddTime, Map1} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) -> maps:put(I, I, Acc) end, Map0, lists:seq(1, ?TEST_SIZE))
    end),

    %% Update Elements
    {UpdateTime, Map2} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) -> maps:put(I, I + 1, Acc) end, Map1, lists:seq(1, ?TEST_SIZE))
    end),

    %% Delete Elements
    {DeleteTime, Map3} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) -> maps:remove(I, Acc) end, Map2, lists:seq(1, ?TEST_SIZE))
    end),

    %% Read Elements
    {ReadTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> _ = maps:get(I, Map3, undefined) end, lists:seq(1, ?TEST_SIZE))
    end),

    {AddTime, UpdateTime, DeleteTime, ReadTime}.

%% Proplists Benchmark
benchmark_proplists() ->
    PropList0 = [],

    %% Add Elements
    {AddTime, PropList1} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) -> [{I, I} | Acc] end, PropList0, lists:seq(1, ?TEST_SIZE))
    end),

    %% Update Elements
    {UpdateTime, PropList2} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) ->
            [{I, I + 1} | lists:keydelete(I, 1, Acc)]
        end, PropList1, lists:seq(1, ?TEST_SIZE))
    end),

    %% Delete Elements
    {DeleteTime, PropList3} = timer:tc(fun() ->
        lists:foldl(fun(I, Acc) -> lists:keydelete(I, 1, Acc) end, PropList2, lists:seq(1, ?TEST_SIZE))
    end),

    %% Read Elements
    {ReadTime, _} = timer:tc(fun() ->
        lists:foreach(fun(I) -> lists:keyfind(I, 1, PropList3) end, lists:seq(1, ?TEST_SIZE))
    end),

    {AddTime, UpdateTime, DeleteTime, ReadTime}.
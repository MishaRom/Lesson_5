-module(lesson5_task02).
-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

%%% API

%% Create a new cache table
create(TableName) ->
    ets:new(TableName, [named_table, public, {read_concurrency, true}, {write_concurrency, true}]),
    ok.

%% Insert data without expiration time
insert(TableName, Key, Value) ->
    insert(TableName, Key, Value, infinity).

%% Insert data with expiration time (in seconds)
insert(TableName, Key, Value, TimeToLive) ->
    ExpirationTime = case TimeToLive of
        infinity -> infinity;
        _ -> calendar:universal_time_to_local_time(calendar:now_to_universal_time(erlang:now())) + TimeToLive
    end,
    ets:insert(TableName, {Key, Value, ExpirationTime}),
    ok.

%% Lookup value by key
lookup(TableName, Key) ->
    case ets:lookup(TableName, Key) of
        [{Key, Value, ExpirationTime}] ->
            case ExpirationTime of
                infinity -> Value;
                _ ->
                    CurrentTime = calendar:universal_time_to_local_time(calendar:now_to_universal_time(erlang:now())),
                    if
                        CurrentTime =< ExpirationTime -> Value;
                        true -> undefined
                    end
            end;
        [] -> undefined
    end.

%% Delete obsolete data
delete_obsolete(TableName) ->
    CurrentTime = calendar:universal_time_to_local_time(calendar:now_to_universal_time(erlang:now())),
    Fun = fun({Key, _Value, ExpirationTime}) ->
        case ExpirationTime of
            infinity -> false;
            _ -> CurrentTime > ExpirationTime
        end
    end,
    ets:select_delete(TableName, [{{'$1', '$2', '$3'}, [{const, {Fun, []}}], [true]}]),
    ok.
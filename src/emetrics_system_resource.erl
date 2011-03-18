-module(emetrics_system_resource).

-export([init/1, content_types_provided/2, to_json/2, allowed_methods/2]).

-include("emetrics.hrl").
-include_lib("webmachine/include/webmachine.hrl").

init(_) -> {ok, undefined}.

content_types_provided(ReqData, Context) ->
    {[{"application/json", to_json}], ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET'], ReqData, Context}.

to_json(ReqData, Context) ->
    {mochijson2:encode(get_system_info()), ReqData, Context}.

get_system_info() ->
    [{Key, convert_system_info({Key, erlang:system_info(Key)})} || Key <- ?SYSTEM_INFO].

convert_system_info({allocated_areas, List}) ->
    [convert_allocated_areas(Value) || Value <- List];
convert_system_info({allocator, {_,_,_,List}}) ->
    List;
convert_system_info({c_compiler_used, {Compiler, Version}}) ->
    [{compiler, Compiler}, {version, convert_c_compiler_version(Version)}];
convert_system_info({driver_version, Value}) ->
    list_to_binary(Value);
convert_system_info({machine, Value}) ->
    list_to_binary(Value);
convert_system_info({otp_release, Value}) ->
    list_to_binary(Value);
convert_system_info({scheduler_bindings, Value}) ->
    tuple_to_list(Value);
convert_system_info({system_version, Value}) ->
    list_to_binary(Value);
convert_system_info({system_architecture, Value}) ->
    list_to_binary(Value);
convert_system_info({version, Value}) ->
    list_to_binary(Value);
convert_system_info({_, Value}) ->
    Value.

convert_allocated_areas({Key, Value1, Value2}) ->
    {Key, [Value1, Value2]};
convert_allocated_areas({Key, Value}) ->
    {Key, Value}.

convert_c_compiler_version({A, B, C}) ->
    list_to_binary(io_lib:format("~p.~p.~p", [A, B, C]));
convert_c_compiler_version({A, B}) ->
    list_to_binary(io_lib:format("~p.~p", [A, B])).

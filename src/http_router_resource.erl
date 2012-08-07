%% @author author <anton@alley.se>
%% @copyright 2012 Anton Lindstrom.
%% @doc Virtualhost proxy. Hostnames stored in Redis.

-module(http_router_resource).
-export([
  init/1,
  set_headers/2,
  retrieve_host/1,
  proxy_request/2,
  service_available/2
  ]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
    {ok, undefined}.

%% Check if redis backend is available and run proxy_request
%% Return 503 if invalid
service_available(ReqData, _State) ->
    Host = wrq:get_req_header("Host", ReqData),
    HostWithoutPort = re:replace(
        Host,
        "\:.*",
        "",
        [{return,list}]),

    HostData = retrieve_host(HostWithoutPort),
    {_ConnectionState, _RespTuple} = proxy_request(ReqData, HostData),

    case _ConnectionState of
        true ->
            { _Status, _RespHeaders, _RespBody} = _RespTuple,

            %% stop resource processing here and return data
            NewReqData = set_headers(_RespTuple, ReqData),
            {{halt, list_to_integer(_Status)}, NewReqData, _State};
        _ ->
          {false, ReqData, _State}
    end.

%% Set headers
%%
set_headers({_Status, _Headers, _Body}, ReqData) ->
    wrq:set_resp_headers(_Headers, wrq:set_resp_body(_Body, ReqData)).

%% Proxy request to backend
proxy_request(_RP, {error, _Msg}) -> {false, {}};
proxy_request(RP, {ok, _Server}) ->

    %% point path at server
    Path = lists:append(
             [_Server,
              wrq:disp_path(RP),
              case wrq:req_qs(RP) of
                  [] -> [];
                  Qs -> [$?|mochiweb_util:urlencode(Qs)]
              end]),

    %% translate webmachine details to ibrowse details
    Headers = clean_request_headers(
                mochiweb_headers:to_list(wrq:req_headers(RP))),
    Method = wm_to_ibrowse_method(wrq:method(RP)),
    ReqBody = case wrq:req_body(RP) of
                  undefined -> [];
                  B -> B
              end,

    ibrowse:start(),

    case ibrowse:send_req(Path, Headers, Method, ReqBody) of
        {ok, Status, SHeaders, RespBody} ->
            {true, {Status, SHeaders, RespBody}};
        _ ->
            {false, {}}
    end.


%% retrieve server address based on hostname from redis
%% example response: {ok, 'http://example.com:80/'}
retrieve_host(Hostname) ->
    process_flag(trap_exit, true),

    case catch eredis:start_link() of
        {'EXIT', {connection_error, _}} ->
            {error, "Unable to connect to database!"};
        {ok, DB} ->
            {_, Server} = eredis:q(DB, ["GET", Hostname]),

            case is_binary(Server) of
                true  -> {ok, binary_to_list(Server)};
                false -> {error, "Could not find server for that hostname!"}
            end;
        _ -> {error, "Unknown"}
    end.

%% ibrowse will recalculate Host and Content-Length headers,
%% and will muck them up if they're manually specified
clean_request_headers(Headers) ->
    [{K,V} || {K,V} <- Headers,
              K /= 'Host', K /= 'Content-Length'].

%% webmachine expresses method as all-caps string or atom,
%% while ibrowse uses all-lowercase atom
wm_to_ibrowse_method(Method) when is_list(Method) ->
    list_to_atom(string:to_lower(Method));
wm_to_ibrowse_method(Method) when is_atom(Method) ->
    wm_to_ibrowse_method(atom_to_list(Method)).

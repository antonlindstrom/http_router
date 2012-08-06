%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the http_router application.

-module(http_router_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for http_router.
start(_Type, _StartArgs) ->
    http_router_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for http_router.
stop(_State) ->
    ok.

{application,http_router,
             [{description,"http_router"},
              {vsn,"1"},
              {modules,[http_router,http_router_app,http_router_resource,
                        http_router_sup,redis_proxy]},
              {registered,[]},
              {applications,[kernel,stdlib,inets,crypto,mochiweb,webmachine]},
              {mod,{http_router_app,[]}},
              {env,[]}]}.

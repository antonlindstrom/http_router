# http-router

The project was built to be able to dynamically proxy pages from a Redis
database. Depending on which HTTP Host header it will be routed to different
locations. The HTTP Host name and location is set in a Redis database and
can be changed at any time to be able to add or remove backend/names.

This is well suited for a dynamic environment, for example automatic deploys
or PaaS.

Proxy is build on webmachine, ibrowse and eredis. It is heavily influenced and
shamelessly half-stolen from Bryan Fink's
[wmexamples](https://bitbucket.org/bryan/wmexamples/).

http-router is a project to learn Erlang and use it in real projects.

## Usage

http-router fetches a key from Redis based on the host header and redirects to
the key.

Example: `app.example.com` => `http://localhost:3000/`

The request to app.example.com will then be proxied to localhost:3000.

The proxy listens on port 8000. Redis should be on the local host listening on
the default port (6379).

The following environment variables changes default behaviour:

    HTTP_PORT=80            # Set listening port to 80
    REDIS_HOST=192.168.1.5  # Set Redis host to 192.168.1.5
    REDIS_PORT=5000         # Set Redis port to 5000

#### Quickstart

    make
    ./start.sh

#### Step by step

Serving `http://localhost:3000` through the proxy on hostname 
`app.example.com` (proxy is listening on port 8000):

1. Install redis-server (Ubuntu: apt-get install redis-server)
2. Install erlang (Ubuntu: apt-get install erlang-base)
3. Insert a host into redis (See below)
4. Clone this repo: `git clone git://github.com/antonlindstrom/http_router.git`
5. Compile: `make`
6. Try it: `./start.sh`
7. Point app.example.com to your host in `/etc/hosts`
8. Insert mapping in redis, see the description below.
9. Enter app.example.com:8000 in your browser.

Adding a virtualhost in redis:

    $ redis-cli
    redis 127.0.0.1:6379> set app.example.com "http://localhost:3000/"

### Release

There is a sample `reltool.config` in the rel/ directory. Do the following to
release:

    cd rel/
    ../rebar create-node nodeid=http_router
    ../rebar generate

Run the release:

    ./rel/http_router/bin/http_router start

## Similar projects

* [hipache](https://github.com/dotcloud/hipache) - a distributed HTTP and
websocket proxy.

## Known issues

You may recieve:

    {mochiweb_socket_server,310,{acceptor_error,{error,accept_failed}}}

This is a ulimit problem, increase the ulimit-limit and it should continue to
serve requests (and responses).

GZIP:ed pages will not work, the proxy will not serve the request and curl says:

    curl: (56) Problem (2) in the Chunked-Encoded data

## Future improvements

* Add logging

## Contributions

I would love to get some more pointers on how to make this more effective and
to get it to run faster.

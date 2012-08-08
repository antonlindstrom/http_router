## http-router

The project was built to be able to dynamically proxy pages from a Redis
database.

Proxy is build on webmachine, ibrowse and eredis. It is heavily influenced and
shamelessly half-stolen from Bryan Fink's
[wmexamples](https://bitbucket.org/bryan/wmexamples/).

http-router is a project to learn Erlang and use it in real projects.

### Quickstart

    make
    ./start.sh

### Release

There is a sample `reltool.config` in the rel/ directory. Do the following to
release:

    cd rel/
    ../rebar create-node nodeid=http_router
    ../rebar generate

Run the release:

    ./rel/http_router/bin/http_router start

## Usage

http-router fetches a key from Redis based on the host header and redirects to
the key.

Example: `app.example.com` => `http://localhost:3000/`

The request to app.example.com will then be proxied to localhost:3000. With
Redis we can also do fun stuff like expiring apps.

The proxy listens on port 8000. Redis should be on the local host listening on
the default port (6379).

#### Step by step

Serving `http://localhost:3000` through the proxy on hostname 
`app.example.com`:

1. Install redis-server (Ubuntu apt-get install redis-server)
2. Install erlang (Ubuntu: apt-get install erlang-base)
3. Insert a host into redis
    redis-cli
    redis 127.0.0.1:6379> set app.example.com "http://antonlindstrom.com/"
4. Clone this repo: `git clone git://github.com/antonlindstrom/http_router.git`
5. Compile: `make`
6. Try it: `./start.sh`
7. Point app.example.com to your host in `/etc/hosts`
8. Enter app.example.com:8000 in your browser.

## Similar projects

* [hipache](https://github.com/dotcloud/hipache) - a distributed HTTP and
websocket proxy.

## Known issues

You may recieve:

    {mochiweb_socket_server,310,{acceptor_error,{error,accept_failed}}}

This is a ulimit problem, increase the ulimit-limit and it should continue to
serve requests (and responses).

## Future improvements

* Add logging

### Contributions

I would love to get some more pointers on how to make this more effective and
to get it to run faster.

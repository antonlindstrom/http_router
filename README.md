## http-router

The project was built to be able to dynamically proxy pages from a Redis db.

Proxy is build on webmachine, ibrowse and eredis. It is heavily influenced and
shamelessly half-stolen from Bryan Fink's
[wmexamples](https://bitbucket.org/bryan/wmexamples/).

http-router is a project to learn Erlang and use it in real projects.

### Quickstart

    make
    ./start.sh

## Usage

http-router fetches a key from Redis based on the host header and redirects to
the key.

Example: `app.example.com` => `http://localhost:3000/`

The request to app.example.com will then be proxied to localhost:3000. With 
Redis we can also do fun stuff like expiring apps.

### Contributions

I would love to get some more pointers on how to make this more effective and
to get it to run faster.

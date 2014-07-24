simple stats server
===================

dead-simple resource stats for Node.js servers

  * [introduction](#introduction)
  * [getting started](#getting-started)
  * [documentation](#documentation)

introduction
------------

Sometimes all you need is the basic resource stats Node core exposes.
But really you'd like it as a JSON endpoint.  And maybe you want to be
able to check that your database connection is healthy or count the
number of requests you're getting.  Just a few simple things, exposed
as a REST endpoint.

getting started
---------------

Install it with NPM.

```sh
> npm install --save simple-stats-server
```

The easiest way to use the server is to mount the connect/express-style
middleware:

```coffeescript
sss = require 'simple-stats-server'
stats = sss()

express = require 'express'
app = express()

# serve the REST API from the /stats path
app.use '/stats', stats

app.listen 3000
```

Now visit the stats endpoint.

```sh
> curl localhost:3000/stats

{"cpu":[0.32],"memory":{"system...
```

Add some route counters and system checks.

```coffeescript
# mount early
app.use stats.count 'requests'
app.use '/api', stats.count 'api calls'

stats.check 'database connection', (cb) ->
  db.checkConnection (err, isUp) ->
    cb not err and isUp
```

documentation
-------------

  * [REST api](#rest-api)
  * [Server api](#server-api)
    * [sss()](#sss)
    * [stats.check(name, predicate)](#statscheckname-predicate)
    * [stats.count(name)](#statscountname)
    * [stats.get(path, cb)](#statsgetpath-cb)

### REST api ###

The simple stats server REST API is simple.  The only method supported
is GET.  Get the URL `/` to retrieve the entire data structure, or
drill down by appending keys as path levels.  For instance, to get the
current process uptime, get `/uptime/process`.

The data structure looks something like this:

```json
{
  "check": {
    "ping": true
  },
  "count": {
    "stats": 2
  },
  "cpu": {
    "1s": [
      0.12,
      0.0297029702970297,
    ],
    "5s": [
      0.12224448897795591,
      0.04183266932270916,
    ],
    "15s": [
      0.10494652406417113,
      0.09886439545758183,
    ],
    "1m": [
      0.08882952078811154,
      0.0733822548365577,
    ]
  },
  "memory": {
    "system": {
      "total": 16763977728,
      "free": 9046654976
    },
    "process": {
      "rss": 38989824,
      "heapTotal": 31139328,
      "heapUsed": 16797672
    }
  },
  "uptime": {
    "system": 174728.443475012,
    "process": 17.979023792984663
  },
  "versions": {
    "http_parser": "1.0",
    "node": "0.10.15",
    "v8": "3.14.5.9",
    "ares": "1.10.0",
    "uv": "0.10.13",
    "zlib": "1.2.8",
    "modules": "11",
    "openssl": "1.0.1f",
    "stats": "0.0.5"
  }
}
```

### Server api ###

#### sss() ###

The return value of the exported function is a *simple-stats-server*.
It acts as connect/express style middleware, so just mount it directly
in your app.  In express style, mount it at a subdirectory:

```coffeescript
sss = require 'simple-server-stats'
stats = sss()
app.use '/stats', stats
```

#### stats.check(name, predicate) ####

Add a status check to the stats server.  The `name` is used for the
JSON representation as well as the URL.  Spaces are replaced with
dashes and the whole thing is downcased.  The function `predicate`
determines the current status.  It can be written in one of two forms,
synchronous, which is nullary `-> Boolean`, and asynchronous, which is
unary `(cb) ->`.  The latter form callsback with a truthy or falsy
value, where the former returns it.

```coffeescript
# a basic alive check (this is what ping is)
stats.check 'alive', -> yes

# check the status of the database connection
stats.check 'database', (cb) ->
  myDatabase.checkConnection (error, isAlive) ->
    cb not error and isAlive
```

#### stats.count(name) ####

Creates a simple counter and returns it.  The `name` is treated the
same as in `check` above, downcased and space-to-dashed.  The returned
counter has the signature `(req, res, next) ->`, and will call `next`
if it's a function, so the counter can be used directly as middleware.
You can also use the counter anywhere else in your application that
you'd like to count events.

```coffeescript
# mount this early to count all requests
app.use stats.count 'requests'

# create a custom event counter
recordEvent = stats.count 'custom event'
recordEvent()
recordEvent()
recordEvent()
```

#### stats.get(path, cb) ####

If you don't have an express application to mount the middleware,
you can use the `get` method to write your own middleware appropriate
to your server setup.  Call this method to get the JSON for the REST
api.  `path` should be the relative path for the stats server (the
root `/` will return the whole structure).  The function `cb` should
have the signature `(err, result) ->`.  If the path doesn't match
anything, `err` is `404`.

#### stats.end() ####

The server will set up an interval timer to poll the cpu.  Use this
method to cancel that timer when shutting down the server.

##### ╭╮☲☲☲╭╮ #####

# simple server stats

__ = require 'something-something'
{parse} = require 'url'
pathMatch = require 'path-match'

Collection = require './collection'
Checker = require './modules/checker'
Counter = require './modules/counter'
metrics = require './metrics'

module.exports = sss = ->
  match = pathMatch
    sensitive: no
    strict: yes
    end: yes
  
  route = (path, fn) ->
    match: match path
    handle: fn

  middleware = (req, res, next) ->
    middleware.get parse(req.url).pathname, (err, result) ->
      return res.send err if err
      res.send result

  checkers = new Collection Checker
  counters = new Collection Counter

  checkers.add 'ping', -> yes
  recordHit = counters.add 'stats'

  middleware.check = checkers.add
  middleware.count = counters.add

  modules =
    check: checkers
    count: counters

  all = {}
  for name of modules
    all[name] = "/#{name}"
  for name of metrics
    all[name] = "/#{name}"

  routes = [
      route '/', (params, cb) ->
        __.map all, get, cb
    ]
    .concat Object.keys(modules).map (type) ->
      collection = modules[type]
      route "/#{type}", (params, cb) ->
        resolve = (fn, done) ->
          fn (val) -> done null, val
        __.map collection.getAll(), resolve, cb

    .concat Object.keys(modules).map (type) ->
      collection = modules[type]
      route "/#{type}/:name", (params, cb) ->
        return cb 404 unless params.name in collection.getNames()

        handle = collection.get(params.name)
        handle (value) -> cb null, value

    .concat Object.keys(metrics).map (type) ->
      metric = metrics[type]
      route "/#{type}", (params, cb) ->
        resolve = (fn, done) -> fn done
        __.map metric, resolve, cb

    .concat Object.keys(metrics).map (type) ->
      metric = metrics[type]
      route "/#{type}/:name", (params, cb) ->
        return cb 404 unless params.name of metric

        metric[params.name] cb

  middleware.get = (path, cb) ->
    recordHit()
    get path, cb

  get = (path, cb) ->
    for route in routes
      params = route.match path
      return route.handle params, cb if params
    cb 404

  middleware

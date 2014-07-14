# example app

express = require 'express'
sss = require '../../src'

app = express()
stats = sss()

app.use stats.count 'requests'
app.use '/stats', stats

app.get '/', (req, res, next) ->
  if Math.random() < 0.1
    next 'oh no!\n'
  else
    res.send 'hello, world!\n'

recordError = stats.count 'error'
app.use (err, req, res, next) ->
  recordError()
  res.send 500, err

app.listen 3000
console.log 'app listening on localhost:3000'

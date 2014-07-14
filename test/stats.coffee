# stats tests

os = require 'os'

{should} = require './helper'

sss = require '../src'

describe 'stats', ->
  stats = beforeEach -> stats = sss()

  describe 'check', ->
    it 'adds a checker', ->
      called = no
      stats.check 'foobar', -> called = yes

      stats.get '/check/foobar', (err, result) ->
        should.not.exist err
        called.should.be.true
        result.should.be.true

      called.should.be.true

    it 'has a ping by default', ->
      stats.get '/check/ping', (err, result) ->
        should.not.exist err
        result.should.be.true

    it 'has an index view', ->
      stats.get '/check', (err, result) ->
        should.not.exist err
        result.should.have.property 'ping'
        result.ping.should.be.true

      stats.check 'foobar', (cb) -> cb null, no

      stats.get '/check', (err, result) ->
        should.not.exist err
        result.should.have.property 'ping'
        result.ping.should.be.true
        result.should.have.property 'foobar'
        result.foobar.should.be.false

  describe 'count', ->
    it 'adds a counter', ->
      foobars = stats.count 'foobar'

      count = 0

      stats.get '/count/foobar', (err, result) ->
        should.not.exist err
        result.should.equal 0
        count += 1

      foobars()
      stats.get '/count/foobar', (err, result) ->
        should.not.exist err
        result.should.equal 1
        count += 1

      foobars()
      stats.get '/count/foobar', (err, result) ->
        should.not.exist err
        result.should.equal 2
        count += 1

      count.should.equal 3

    it 'has a stats counter by default', ->
      stats.get '/count/stats', (err, result) ->
        should.not.exist err
        result.should.equal 1

      stats.get '/count/stats', (err, result) ->
        should.not.exist err
        result.should.equal 2

      stats.get '/count/stats', (err, result) ->
        should.not.exist err
        result.should.equal 3

    it 'has an index view', ->
      stats.get '/count', (err, result) ->
        should.not.exist err
        result.should.have.property 'stats'
        result.stats.should.equal 1

      foobars = stats.count 'foobar'

      stats.get '/count', (err, result) ->
        should.not.exist err
        result.should.have.property 'stats'
        result.stats.should.equal 2
        result.should.have.property 'foobar'
        result.foobar.should.equal 0

      foobars()
      foobars()

      stats.get '/count', (err, result) ->
        should.not.exist err
        result.should.have.property 'stats'
        result.stats.should.equal 3
        result.should.have.property 'foobar'
        result.foobar.should.equal 2

  describe 'versions', ->
    it 'has an index view', ->
      stats.get '/versions', (err, result) ->
        should.not.exist err
        result.should.have.property 'v8'
        result.should.have.property 'node'
        result.should.have.property 'stats'
        result.v8.should.match /[0-9]+\.[0-9]+\.[0-9]+/
        result.node.should.match /[0-9]+\.[0-9]+\.[0-9]+/
        result.stats.should.match /[0-9]+\.[0-9]+\.[0-9]+/

    it 'drills down', ->
      test = (stat) ->
        stats.get "/versions/#{stat}", (err, result) ->
          should.not.exist err
          "#{result}".should.equal result

      test 'v8'
      test 'node'
      test 'stats'

  describe 'uptime', ->
    it 'has an index view', ->
      stats.get '/uptime', (err, result) ->
        should.not.exist err
        result.should.have.property 'system'
        result.should.have.property 'process'
        parseFloat result.system
          .should.equal result.system
        parseFloat result.process
          .should.equal result.process

    it 'drills down', ->
      test = (stat) ->
        stats.get "/uptime/#{stat}", (err, result) ->
          should.not.exist err
          parseFloat(result).should.equal result

      test 'system'
      test 'process'

  describe 'memory', ->
    it 'has an index view', ->
      stats.get '/memory', (err, result) ->
        should.not.exist err
        result.should.have.property 'heap'
        result.should.have.property 'system'
        result.should.have.property 'process'
        parseFloat result.heap
          .should.equal result.heap
        parseFloat result.system
          .should.equal result.system
        parseFloat result.process
          .should.equal result.process

    it 'drills down', ->
      test = (stat) ->
        stats.get "/memory/#{stat}", (err, result) ->
          should.not.exist err
          parseFloat(result).should.equal result

      test 'heap'
      test 'system'
      test 'process'

  describe 'cpu', ->
    it 'has an index view', (done) ->
      @timeout 1000 * 61
      stats.get '/cpu', (err, result) ->
        should.not.exist err
        result.should.have.property '1s'
        result.should.have.property '5s'
        result.should.have.property '15s'
        result.should.have.property '1m'
        result['1s'].should.have.length os.cpus().length
        result['5s'].should.have.length os.cpus().length
        result['15s'].should.have.length os.cpus().length
        result['1m'].should.have.length os.cpus().length
        done()

    it 'drills down', (done) ->
      @timeout 1000 * 16
      count = 0

      test = (stat) ->
        count += 1
        stats.get "/cpu/#{stat}", (err, result) ->
          should.not.exist err
          should.exist result.length
          count -= 1
          done() if count is 0

      test '1s'
      test '5s'
      test '15s'

  it 'has an index view', (done) ->
    @timeout 1000 * 61
    stats.get '/', (err, result) ->
      should.not.exist err
      result.should.have.property 'cpu'
      result.cpu.should.have.property '1s'
      result.cpu['1s'].should.have.property 'length'
      result.should.have.property 'memory'
      result.memory.should.have.property 'process'
      result.should.have.property 'uptime'
      result.uptime.should.have.property 'process'
      result.should.have.property 'versions'
      result.versions.should.have.property 'stats'
      result.should.have.property 'count'
      result.count.should.have.property 'stats'
      result.should.have.property 'check'
      result.check.should.have.property 'ping'
      done()

  it 'acts as middleware', (done) ->
    @timeout 1000 * 61
    req = url: '/'

    res = send: ->
      sent = arguments[0]

      sent.should.not.be.false
      nexted.should.be.false

      sent.should.not.equal 404
      sent.should.have.property 'cpu'

      done()

    nexted = no
    next = -> nexted = yes

    stats req, res, next

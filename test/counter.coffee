# counter tests

require './helper'

Counter = require '../src/modules/counter'

describe 'Counter', ->
  counter = beforeEach -> counter = new Counter()

  countToThree = ->
    counter.backend (count) ->
      count.should.equal 0

    counter.frontend()

    counter.backend (count) ->
      count.should.equal 1

    counter.frontend()

    counter.backend (count) ->
      count.should.equal 2

    counter.frontend()

    counter.backend (count) ->
      count.should.equal 3

  describe 'backend', ->
    it 'calls back with count of calls to frontend', countToThree

  describe 'frontend', ->
    it 'increases the call count', countToThree

    it 'calls next callback for middleware support', ->
      called = no
      counter.frontend {}, {}, ->
        called = yes

      called.should.be.true

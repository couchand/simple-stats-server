# checker tests

require './helper'

Checker = require '../src/modules/checker'

describe 'Checker', ->
  describe 'backend', ->
    it 'calls the checker function', ->
      called = no
      checker = new Checker -> called = yes

      checker.backend -> called.should.be.true

    it 'callsback true if checker returns truthy', ->
      test = (value) ->
        checker = new Checker -> value

        checker.backend (result) -> result.should.be.true

      test yes
      test 1
      test 'foobar'

    it 'callsback false if checker returns falsy', ->
      test = (value) ->
        checker = new Checker -> value

        checker.backend (result) -> result.should.be.false

      test no
      test 0
      test ''

    it 'callsback true if checker callsback truthy', ->
      test = (value) ->
        checker = new Checker (cb) -> cb value

        checker.backend (result) -> result.should.be.true

      test yes
      test 1
      test 'foobar'

    it 'callsback false if checker callsback falsy', ->
      test = (value) ->
        checker = new Checker (cb) -> cb value

        checker.backend (result) -> result.should.be.false

      test no
      test 0
      test ''

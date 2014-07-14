# cpu calculation tests

require './helper'

utilization = require '../src/metrics/helper/cpu-calc.coffee'

describe 'utilization', ->
  describe 'sumIdle', ->
    it 'returns the "idle" property', ->
      utilization
        .sumIdle
          other: 12
          idle: 42
        .should.equal 42

  describe 'sumBusy', ->
    it 'sums all but the "idle" property', ->
      utilization
        .sumBusy
          foo: 1
          bar: 2
          baz: 3
          idle: 42
        .should.equal 6

  it 'calculates the percentage time busy', ->
    test = (expected, times) ->
      start =
        busy: 5
        idle: 5

      finish =
        busy: start.busy + times.busy
        idle: start.idle + times.idle

      utilization { times: start }, { times: finish }
        .should.equal expected

    test 0.25,
      busy: 1
      idle: 3

    test 0.50,
      busy: 1
      idle: 1

    test 0.75,
      busy: 3
      idle: 1

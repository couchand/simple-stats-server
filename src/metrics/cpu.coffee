# cpu utilization sampler

os = require 'os'

utilization = require './helper/cpu-calc'

# sample the cpu regularly
timer = no
samples = []
maxInterval = 61

# sample the cpu

#   ([interval], [cb]) ->
#     interval defaults to 1s
#     cb defaults to noop (pretty useless)

#   samples the cpu at the start and end of interval, callsback with
#   the percentage utilization of each cpu during that interval.

module.exports = sample = ->

  # extract parameters
  if typeof arguments[0] is 'number'
    [interval, cb] = arguments
  else
    [cb] = arguments

  # default parameters
  interval ?= 1
  cb = (->) unless typeof cb is 'function'

  doCalc = ->
    initial = samples[-1-interval..][0]
    final   = samples[-1..][0]

    # calculate utilization
    diffs = [0...initial.length].map (i) ->
      utilization initial[i], final[i]

    cb null, diffs
    diffs

  if samples.length <= interval
    maxInterval = interval + 1 if maxInterval <= interval
    setTimeout doCalc, 1000 * interval - samples.length + 1
  else
    doCalc()

add = (label, timeout) ->
  sample[label] = sample.bind null, timeout

add  '1s',  1
add  '5s',  5
add '15s', 15
add  '1m', 60

Object.defineProperty sample, 'cancel',
  value: ->
    return unless timer
    clearInterval timer
    timer = no

Object.defineProperty sample, 'collect',
  value: ->
    return if timer
    timer = setInterval (->
      samples.unshift() if samples.length >= maxInterval
      samples.push os.cpus()
    ), 1000

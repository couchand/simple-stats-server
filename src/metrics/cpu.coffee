# cpu utilization sampler

os = require 'os'

utilization = require './helper/cpu-calc'

# sample the cpu

#   ([interval], [cb]) ->
#     interval defaults to 1000ms
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
  interval ?= 1000
  cb = (->) unless typeof cb is 'function'

  # take initial reading
  initial = os.cpus()

  setTimeout (->

    # take final reading
    final = os.cpus()

    # calculate utilization
    diffs = [0...initial.length].map (i) ->
      utilization initial[i], final[i]

    # callback
    cb null, diffs

  ), interval

add = (label, timeout) ->
  sample[label] = sample.bind null, timeout

add '1s',  1000
add '5s',  1000 * 5
add '15s', 1000 * 15
add '1m',  1000 * 60

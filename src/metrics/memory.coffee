# memory utilization samplers

os = require 'os'

# sample the memory usage
#   ([cb]) ->
#     cb defaults to noop

#   samples the point-in-time memory usage, callsback with and returns
#   the usage information.

# one for each of system and process

module.exports =
  system: (cb) ->
    cb = (->) unless typeof cb is 'function'

    util =
      total: os.totalmem()
      free: os.freemem()

    cb null, util
    util

  process: (cb) ->
    cb = (->) unless typeof cb is 'function'

    util = process.memoryUsage()

    cb null, util
    util

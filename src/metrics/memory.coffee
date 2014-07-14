# memory utilization samplers

os = require 'os'

# sample the memory usage
#   ([cb]) ->
#     cb defaults to noop

#   samples the point-in-time memory usage, callsback with and returns
#   the percentage (for flexibility)

# one for each of system, process, heap

module.exports =
  system: (cb) ->
    cb = (->) unless typeof cb is 'function'

    total = os.totalmem()
    free = os.freemem()

    cb null, util = (total - free) / total
    util

  process: (cb) ->
    cb = (->) unless typeof cb is 'function'

    total = os.totalmem()
    used = process.memoryUsage().rss

    cb null, util = used / total
    util

  heap: (cb) ->
    cb = (->) unless typeof cb is 'function'

    mem = process.memoryUsage()

    cb null, util = mem.heapUsed / mem.heapTotal
    util

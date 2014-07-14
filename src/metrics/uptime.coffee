# uptime samplers

os = require 'os'

# sample the uptime
#   ([cb]) ->
#     cb defaults to noop (pretty useless)

#   samples the current uptime, callsback with and returns number of
#   seconds (for flexibility)

#   one each for system and process

module.exports =
  system: (cb) ->
    cb = (->) unless typeof cb is 'function'

    cb null, time = os.uptime()

  process: (cb) ->
    cb = (->) unless typeof cb is 'function'

    cb null, time = process.uptime()
    time

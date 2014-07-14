# cpu diff of sums calculation

# sum the busy times
sumBusy = (times) ->
  (time for name, time of times when name isnt 'idle')
    .reduce (a, b) -> a + b

# sum (read, extract) the idle time
sumIdle = (times) ->
  times.idle

# calculate utilization of a cpu
utilization = (initial, final) ->
  t0 = initial.times
  t1 = final.times
  sum0 = sumBusy t0
  sum1 = sumBusy t1

  busy = sumBusy(t1) - sumBusy(t0)
  idle = sumIdle(t1) - sumIdle(t0)

  busy / ( idle + busy )

# export helpers for testing
utilization.sumBusy = sumBusy
utilization.sumIdle = sumIdle

# primary export
module.exports = utilization

# chubby checker

class Checker
  constructor: (@_fn) ->

  backend: (cb) => # autobind
    if @_fn.length is 1
      @_fn (val) -> cb not not val
    else
      cb not not @_fn()

module.exports = Checker

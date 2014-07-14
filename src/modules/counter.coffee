# count chocula

class Counter
  constructor: ->
    @_count = 0

  backend: (cb) => # autobind
    cb @_count
    @_count

  frontend: (req, res, next) => # autobind
    @_count += 1

    next() if typeof next is 'function'

module.exports = Counter

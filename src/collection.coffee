# stats collection

normalize = (name) ->
  (name or '')
    .toLowerCase()
    .replace /\s+/g, '-'

class Collection
  constructor: (@_module) ->
    unless @_module?
      throw new Error 'Collection expects a stats module'

    @_stats = {}

  getNames: =>
    Object.keys @_stats

  add: (nm) =>
    name = normalize nm
    args = (arguments[i] for i in [1...arguments.length])

    if name of @_stats
      throw new Error "Collection already has a stat named '#{name}'"

    stat = @_stats[name] = new @_module args[0], args[1], args[2]

    stat.frontend

  get: (nm) =>
    name = normalize nm

    unless name of @_stats
      throw new Error "Collection has no stat named '#{name}'"

    stat = @_stats[name]

    stat.backend

  getAll: =>
    all = {}
    all[name] = stat.backend for name, stat of @_stats
    all

module.exports = Collection

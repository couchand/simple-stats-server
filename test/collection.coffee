# stats collection tests

require './helper'

Collection = require '../src/collection'

class FakeModule
  constructor: ->

describe 'Collection', ->
  describe 'constructor', ->
    it 'expects a stats module', ->
      (-> new Collection()).should.throw /module/

  describe 'getNames', ->
    describe 'with empty collection', ->
      it 'returns an empty list', ->
        collection = new Collection FakeModule

        collection.getNames().should.have.length 0

    describe 'with named stats', ->
      it 'returns all stats names', ->
        collection = new Collection FakeModule

        collection.add 'foo'
        collection.add 'bar'
        collection.add 'baz'

        names = collection.getNames()

        names.should.have.length 3
        names.should.have.members ['foo', 'bar', 'baz']

  describe 'add', ->
    it 'adds a named stat to the collection', ->
      collection = new Collection FakeModule

      collection.add 'foobar'

      names = collection.getNames()
      names.should.have.length 1
      names[0].should.equal 'foobar'

    it 'invokes the module constructor', ->
      called = no
      params = no
      class SpyModule
        constructor: ->
          called = yes
          params = arguments

      collection = new Collection SpyModule

      foo = {}
      bar = {}
      baz = {}
      collection.add 'foobar', foo, bar, baz

      called.should.be.true
      params.should.have.length 3
      params[0].should.equal foo
      params[1].should.equal bar
      params[2].should.equal baz

    it 'returns the vivified stat frontend', ->
      called = no
      class Frontender
        constructor: ->
        frontend: =>
          called = yes

      collection = new Collection Frontender
      frontend = collection.add 'foobar'

      frontend()

      called.should.be.true

    it 'throws on addition of the same name', ->
      collection = new Collection FakeModule

      collection.add 'foobar'

      (-> collection.add 'foobar').should.throw /name/

    it 'converts spaces to dashes', ->
      collection = new Collection FakeModule

      collection.add 'foo bar'

      collection.getNames()[0]
        .should.equal 'foo-bar'

    it 'downcases', ->
      collection = new Collection FakeModule

      collection.add 'FOOBAR'

      collection.getNames()[0]
        .should.equal 'foobar'

  describe 'get', ->
    it 'gets the vivified stat backend', ->
      called = no
      class Backender
        constructor: ->
        backend: ->
          called = yes

      collection = new Collection Backender
      collection.add 'foobar'

      backend = collection.get 'foobar'

      backend()

      called.should.be.true

    it 'throws on bad name', ->
      collection = new Collection FakeModule

      (-> collection.get 'foobar').should.throw /name/

    it 'converts spaces to dashes', ->
      collection = new Collection FakeModule

      collection.add 'foo-bar'

      (-> collection.get 'foo bar').should.not.throw /name/

    it 'downcases', ->
      collection = new Collection FakeModule

      collection.add 'foobar'

      (-> collection.get 'FOOBAR').should.not.throw /name/

  describe 'getAll', ->
    it 'gets all the stat backends', ->
      class Countback
        constructor: ->
          @_count = 0
        frontend: =>
          @_count
        backend: =>
          @_count += 1

      collection = new Collection Countback

      foo = collection.add 'foo'
      bar = collection.add 'bar'
      baz = collection.add 'baz'

      all = collection.getAll()

      foo().should.equal 0
      all.should.have.property 'foo'
      all.foo()
      foo().should.equal 1

      bar().should.equal 0
      all.should.have.property 'bar'
      all.bar()
      bar().should.equal 1

      baz().should.equal 0
      all.should.have.property 'baz'
      all.baz()
      baz().should.equal 1

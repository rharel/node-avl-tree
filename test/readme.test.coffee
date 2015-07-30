###
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
###

should = require 'should'
AVLTree = require '../lib/avl'

describe 'readme', ->
  describe 'creation', ->
    t = new AVLTree()

    it 'should be empty', ->
      t.is_empty().should.be.equal true
      (t.root?).should.be.equal false

  describe 'insertion', ->
    t = new AVLTree()
    k = 1
    v = 'hello'
    n = t.insert(k, v)

    it 'should match key and value', ->
      n.key.should.be.equal k
      n.value.should.be.equal v
    it 'should become the root', ->
      t.root.should.be.equal n

  describe 'search', ->
    t = new AVLTree()
    a = t.insert(1, 'hello')
    b = t.insert(2, 'world')

    it 'should return value', ->
      t.search(1).should.be.equal a
      t.search(3).should.be.equal b

  describe 'removal', ->
    t = new AVLTree()
    a = t.insert(1, 'hello')
    b = t.insert(2, 'world')

    it 'should remove and invalidate', ->
      a.is_valid().should.be.equal true
      t.remove(1).should.be.equal 'hello'
      a.is_valid().should.be.equal false

      b.is_valid().should.be.equal true
      b.remove().should.be.equal 'world'
      b.is_valid().should.be.equal false

  describe 'example: sorting', ->
    t = new AVLTree()
    t.insert(2, 'world')
    t.insert(6, 'day')
    t.insert(5, 'beautiful')
    t.insert(3, 'what')
    t.insert(1, 'hello')
    t.insert(4, 'a')

    result = []
    until t.is_empty()
      result.push(t.search(0).remove())

    it 'should sort ascending', ->
      result.join().should.be.equal 'hello world what a beautiful day'

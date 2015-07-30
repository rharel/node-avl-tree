###
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
###

exports.it_should_be_empty = (tree) ->
  it 'should have no root', ->
    (tree.root?).should.be.equal false
  it 'should be empty', ->
    tree.is_empty().should.be.equal true

exports.it_should_match_key_and_value = (node, key, value) ->
  it 'should match the key', ->
    node.key.should.be.equal key
  it 'should match the value', ->
    node.value.should.be.equal value

exports.it_should_be_a_leaf = (node) ->
  it 'should have no children', ->
    (node.left()?).should.be.equal false
    (node.right()?).should.be.equal false
  it 'should be aware that it is a leaf', ->
    node.is_leaf().should.be.equal true
  it 'should have expected height', ->
    node.height().should.be.equal 1
  it 'should have expected balance', ->
    node.balance().should.be.equal 0

exports.it_should_be_the_root = (node, tree) ->
  it 'should be set as the root', ->
    tree.root.should.be.equal node
  it 'should have no parent', ->
    (node.parent?).should.be.equal false
  it 'should be aware that it is the root', ->
    node.is_root().should.be.equal true

exports.it_should_have_children = (node, L = null, R = null) ->
  it 'should ' + (if L? then 'have' else 'have no') + ' left child', ->
    (node.left()?).should.be.equal L?
  it 'should ' + (if R? then 'have' else 'have no') + ' right child', ->
    (node.right()?).should.be.equal R?
  if L?
    it 'should have left child know its parent', ->
      L.parent.should.be.equal node
  if R?
    it 'should have right child know its parent', ->
      R.parent.should.be.equal node
  if !L? and !R?
    it 'should be aware that it is a leaf', ->
      node.is_leaf().should.be.equal true
  else
    it 'should be aware that it is not a leaf', ->
      node.is_leaf().should.be.equal false

exports.it_should_have_props = (node, height, balance) ->
  it 'should have expected height', ->
    node.height().should.be.equal height
  it 'should have expected balance', ->
    node.balance().should.be.equal balance

exports.it_should_be_invalid = (node) ->
  it 'should isolate node', ->
    (node.parent?).should.be.equal false
    (node.left()?).should.be.equal false
    (node.right()?).should.be.equal false
  it 'should invalidate node\'s key', ->
    (node.key?).should.be.equal false
  it 'should invalidate node\'s value', ->
    (node.value?).should.be.equal false
  it 'should have the invalid node flag', ->
    node.is_invalid().should.be.equal true

exports.arrays_are_equal = (a, b) ->
  if a is b
    return true
  if a? or b?
    return false
  if a.length isnt b.length
    return false

  (if a[i] isnt b[i] then return false) for i in [0...a.length]

  return true

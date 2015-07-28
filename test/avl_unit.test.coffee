should = require 'should'
AVLTree = require '../src/avl'

it_should_match_key_and_value = (node, key, value) ->
  it 'should match the key', ->
    node.key.should.be.equal key
  it 'should match the value', ->
    node.value.should.be.equal value

it_should_be_a_leaf = (node) ->
  it 'should have no children', ->
    (node.left()?).should.be.equal false
    (node.right()?).should.be.equal false
  it 'should be aware that it is a leaf', ->
    node.is_leaf().should.be.equal true
  it 'should have expected height', ->
    node.height().should.be.equal 1
  it 'should have expected balance', ->
    node.balance().should.be.equal 0

it_should_be_the_root = (node, tree) ->
  it 'should be set as the root', ->
    tree._root.should.be.equal node
  it 'should have no parent', ->
    (node.parent?).should.be.equal false
  it 'should be aware that it is the root', ->
    node.is_root().should.be.equal true

it_should_have_children = (node, L = null, R = null) ->
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
    it 'should be aware that is is not a leaf', ->
      node.is_leaf().should.be.equal false

it_should_have_props = (node, height, balance) ->
  it 'should have expected height', ->
    node.height().should.be.equal height
  it 'should have expected balance', ->
    node.balance().should.be.equal balance

it_should_be_invalid = (node) ->
  it 'should isolate node', ->
    (node.parent?).should.be.equal false
    (node.left()?).should.be.equal false
    (node.right()?).should.be.equal false
  it 'should invalidate node\'s key', ->
    (node.key?).should.be.equal false
  it 'should invalidate node\'s value', ->
    (node.value?).should.be.equal false

describe 'sanity', ->
  describe 'default initialization', ->
    t = new AVLTree()

    it 'should be empty', ->
      t.is_empty().should.be.equal true
    it 'should have a simple comparator', ->
      t._comparator(3, 2).should.be.above 0
      t._comparator(2, 3).should.be.below 0
      t._comparator(3, 3).should.be.equal 0

  describe 'user initialization', ->
    comparator = (a, b) -> b - a
    t = new AVLTree(comparator)

    it 'should accept user comparator', ->
      t._comparator.should.be.equal comparator

describe 'insertion', ->
  describe 'into an empty tree', ->
    t = new AVLTree
    a = t.insert(0, '0')

    it_should_match_key_and_value(a, 0, '0')
    it_should_be_the_root(a, t)
    it_should_be_a_leaf(a)

  it 'should have a default value of null', ->
    t = new AVLTree
    a = t.insert(0)
    (a.value?).should.be.equal false

  it 'should return null when value is already present', ->
    t = new AVLTree
    a = t.insert(0)
    b = t.insert(0)
    (b?).should.be.equal false

  describe 'balanced', ->
    describe 'into root[height = 1].left', ->
      t = new AVLTree
      a = t.insert(2, '2')
      b = t.insert(1, '1')

      it_should_match_key_and_value(a, 2, '2')
      it_should_be_the_root(a, t)
      it_should_have_children(a, b, null)
      it_should_have_props(a, 2, 1)

      it_should_match_key_and_value(b, 1, '1')
      it_should_be_a_leaf(b)

    describe 'into root[height = 1].right', ->
      t = new AVLTree
      a = t.insert(1, '1')
      b = t.insert(2, '2')

      it_should_match_key_and_value(a, 1, '1')
      it_should_be_the_root(a, t)
      it_should_have_children(a, null, b)
      it_should_have_props(a, 2, -1)

      it_should_match_key_and_value(b, 2, '2')
      it_should_be_a_leaf(b)

  describe 'imbalanced', ->
    test_case = (name, x, y, z) ->
      describe name, ->
        t = new AVLTree
        [vx, vy, vz] = (('' + i) for i in [x, y, z])
        a = t.insert(x, vx)
        b = t.insert(y, vy)
        c = t.insert(z, vz)

        it_should_match_key_and_value(a, x, vx)
        it_should_match_key_and_value(b, y, vy)
        it_should_match_key_and_value(c, z, vz)

        [L, root, R] = [a, b, c].sort((p, q) -> p.key - q.key)

        it_should_be_the_root(root, t)
        it_should_have_children(root, L, R)
        it_should_have_props(root, 2, 0)

        it_should_be_a_leaf(L)
        it_should_be_a_leaf(R)

    test_case('LL', 3, 2, 1)
    test_case('LR', 3, 1, 2)
    test_case('RR', 1, 2, 3)
    test_case('RL', 1, 3, 2)

  describe 'verify structure after inserting [1..7]', ->
    t = new AVLTree
    result = (t.insert(i, '' + i) for i in [1..7])
    [LL, L, LR, root, RL, R, RR] = result

    it_should_match_key_and_value(result[i - 1], i, '' + i) for i in [1..7]

    it_should_be_the_root(root, t)
    it_should_have_children(root, L, R)
    it_should_have_props(root, 3, 0)

    it_should_have_children(L, LL, LR)
    it_should_have_props(L, 2, 0)

    it_should_have_children(R, RL, RR)
    it_should_have_props(R, 2, 0)

    it_should_be_a_leaf(node) for node in [LL, LR, RL, RR]

describe 'search', ->
  describe 'in an empty tree', ->
    t = new AVLTree
    r = t.search(0)

    it 'should return null', ->
      (r?).should.be.equal false

  describe 'in a tree missing the target value', ->
    t = new AVLTree
    t.insert(i, '' + i) for i in [1..7]

    for i in [1..7] by 2
      do (i) ->
        for q in [i - 0.5, i + 0.5]
          do (q) ->
            describe "search(#{q})", ->
              r = t.search(q)
              it_should_match_key_and_value(r, i, '' + i)

  describe 'in a tree containing the target value', ->
    t = new AVLTree
    t.insert(i, '' + i) for i in [1..7]

    for i in [1..7]
      do (i) ->
        describe "search(#{i})", ->
          r = t.search(i)
          it_should_match_key_and_value(r, i, '' + i)

describe 'deletion', ->

  describe 'in an empty tree', ->
    t = new AVLTree
    r = t.delete(0)

    it 'should return null', ->
      (r?).should.be.equal false

  describe 'from a tree missing the deleted value', ->
    t = new AVLTree
    a = t.insert(1, '1')
    r = t.delete(0)

    it 'should return null', ->
      (r?).should.be.equal false

  describe 'from single node tree', ->
    t = new AVLTree
    x = t.insert(1, '1')
    r = t.delete(1)

    it 'should return deleted node\'s value', ->
      r.should.be.equal '1'

    it_should_be_invalid(x)

  describe 'balanced', ->
    describe 'from root[height = 1].left', ->
      t = new AVLTree
      a = t.insert(2, '2')
      x = t.insert(1, '1')
      r = t.delete(1)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '1'

      it_should_be_invalid(x)
      it_should_be_the_root(a, t)
      it_should_be_a_leaf(a)

    describe 'from root[height = 1].right', ->
      t = new AVLTree
      a = t.insert(1, '1')
      x = t.insert(2, '2')
      r = t.delete(2)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '2'

      it_should_be_invalid(x)
      it_should_be_the_root(a, t)
      it_should_be_a_leaf(a)

  describe 'imbalanced', ->
    describe 'LL', ->
      t = new AVLTree
      [x, R, root, L] = (t.insert(i, '' + i) for i in [4, 3, 2, 1])
      r = t.delete(4)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '4'

      it_should_be_invalid(x)

      it_should_be_the_root(root, t)
      it_should_have_children(root, L, R)
      it_should_have_props(root, 2, 0)

      it_should_be_a_leaf(L)
      it_should_be_a_leaf(R)

    describe 'RR', ->
      t = new AVLTree
      [x, L, root, R] = (t.insert(i, '' + i) for i in [1, 2, 3, 4])
      r = t.delete(1)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '1'

      it_should_be_invalid(x)

      it_should_be_the_root(root, t)
      it_should_have_children(root, L, R)
      it_should_have_props(root, 2, 0)

      it_should_be_a_leaf(L)
      it_should_be_a_leaf(R)

    describe 'RL', ->
      t = new AVLTree
      [x, L, R, root] = (t.insert(i, '' + i) for i in [1, 2, 4, 3])
      r = t.delete(1)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '1'

      it_should_be_invalid(x)

      it_should_be_the_root(root, t)
      it_should_have_children(root, L, R)
      it_should_have_props(root, 2, 0)

      it_should_be_a_leaf(L)
      it_should_be_a_leaf(R)

    describe 'LR', ->
      t = new AVLTree
      [x, R, L, root] = (t.insert(i, '' + i) for i in [4, 3, 1, 2])
      r = t.delete(4)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '4'

      it_should_be_invalid(x)

      it_should_be_the_root(root, t)
      it_should_have_children(root, L, R)
      it_should_have_props(root, 2, 0)

      it_should_be_a_leaf(L)
      it_should_be_a_leaf(R)
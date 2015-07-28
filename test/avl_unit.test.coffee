should = require 'should'
AVLTree = require '../src/avl'

describe 'sanity', ->
  describe 'default initialization', ->
    t = new AVLTree()

    it 'should have no children', ->
      (t.left()?).should.be.equal false
      (t.right()?).should.be.equal false
    it 'should be a leaf', ->
      t.is_leaf().should.be.equal true
    it 'should have no parent', ->
      (t.parent?).should.be.equal false
    it 'should be the root', ->
      t.is_root().should.be.equal true
    it 'should have height of 1', ->
      t.height().should.be.equal 1
    it 'should have balance of 0', ->
      t.balance().should.be.equal 0
    it 'should have value of 0', ->
      t.key.should.be.equal 0
    it 'should have nil value', ->
      (t.value?).should.be.equal false
    it 'should have a simple comparator', ->
      t.comparator(3, 2).should.be.above 0
      t.comparator(2, 3).should.be.below 0
      t.comparator(3, 3).should.be.equal 0

  describe 'user initialization', ->
    comparator = (a, b) -> b - a
    t = new AVLTree(3, '3', comparator)

    it 'should accept user value', ->
      t.key.should.be.equal 3
    it 'should accept user value', ->
      t.value.should.be.equal '3'
    it 'should accept user comparator', ->
      t.comparator.should.be.equal comparator

  describe 'root fetching', ->
    it 'should return itself when it is the root', ->
      t = new AVLTree()
      r = t.root()
      r.should.be.equal t
    it 'should return parent when it is a child', ->
      t1 = new AVLTree(); t2 = new AVLTree()
      t2.parent = t1
      r = t2.root()
      r.should.be.equal t1

describe 'insertion', ->
  it 'should return nil when value is already present', ->
    t = new AVLTree(0)
    r = t.insert(0)
    (r?).should.be.equal false

  describe 'balanced', ->
    describe 'into root[height = 1].left', ->
      t = new AVLTree(2)
      r = t.insert(1, '1')

      it 'should spawn a left child', ->
        (t.left()?).should.be.equal true
      it 'should not spawn a right child', ->
        (t.right()?).should.be.equal false
      it 'should return inserted node', ->
        r.should.be.equal t.left()
      it 'should have child know its parent', ->
        r.parent.should.be.equal t
      it 'should contain value', ->
        r.key.should.be.equal 1
      it 'should contain value', ->
        r.value.should.be.equal '1'
      it 'should update own height', ->
        t.height().should.be.equal 2
      it 'should not touch child _height', ->
        r.height().should.be.equal 1
      it 'should update own balance', ->
        t.balance().should.be.equal 1
      it 'should not touch child balance', ->
        r.balance().should.be.equal 0

    describe 'into root[height = 1].right', ->
      t = new AVLTree(2)
      r = t.insert(3, '3')

      it 'should spawn a right child', ->
        (t.right()?).should.be.equal true
      it 'should not spawn a left child', ->
        (t.left()?).should.be.equal false
      it 'should return inserted node', ->
        r.should.be.equal t.right()
      it 'should have child know its parent', ->
        r.parent.should.be.equal t
      it 'should contain value', ->
        r.key.should.be.equal 3
      it 'should contain value', ->
        r.value.should.be.equal '3'
      it 'should update own height', ->
        t.height().should.be.equal 2
      it 'should not touch child _height', ->
        r.height().should.be.equal 1
      it 'should update own balance', ->
        t.balance().should.be.equal -1
      it 'should not touch child balance', ->
        r.balance().should.be.equal 0

  describe 'imbalanced', ->
    test_case = (name, a, b, c) ->
      describe name, ->
        t = new AVLTree(a)
        r1 = t.insert(b)
        r2 = t.insert(c)
        t = t.root()

        it 'should return inserted node', ->
          r1.key.should.be.equal b
          r2.key.should.be.equal c
        it 'root should have two children', ->
          (t.left()?).should.be.equal true
          (t.right()?).should.be.equal true
        it 'root should have both children be leaves', ->
          t.left().is_leaf().should.be.equal true
          t.right().is_leaf().should.be.equal true
        it 'root should have both children know their parent', ->
          t.left().parent.should.be.equal t
          t.right().parent.should.be.equal t
        it 'should update root height', ->
          t.height().should.be.equal 2
        it 'should update children height', ->
          t.left().height().should.equal 1
          t.right().height().should.equal 1
        it 'should update root balance', ->
          t.balance().should.be.equal 0
        it 'should update children balance', ->
          t.left().balance().should.be.equal 0
          t.right().balance().should.be.equal 0

    test_case('LL', 3, 2, 1)
    test_case('LR', 3, 1, 2)
    test_case('RR', 1, 2, 3)
    test_case('RL', 1, 3, 2)

  describe 'verify structure after inserting [1..7]', ->
    t = new AVLTree(1)
    t.insert(i) for i in [2..7]
    t = t.root()

    L = t.left(); LL = L.left(); LR = L.right()
    R = t.right(); RL = R.left(); RR = R.right()

    it 'should have root = 4', ->
      t.key.should.be.equal 4
    it 'should have L = 2', ->
      L.key.should.be.equal 2
    it 'should have LL = 1', ->
      LL.key.should.be.equal 1
    it 'should have LR = 3', ->
      LR.key.should.be.equal 3
    it 'should have R = 6', ->
      R.key.should.be.equal 6
    it 'should have RL = 5', ->
      RL.key.should.be.equal 5
    it 'should have RR = 7', ->
      RR.key.should.be.equal 7

describe 'search', ->
  describe 'in a tree missing the target value', ->
    t = new AVLTree(1, '1')
    t.insert(i, '' + i) for i in [2..7]

    it 'should return the closest leaf', ->
      t.search(0.5).key.should.be.equal 1
      t.search(1.5).key.should.be.equal 1
      t.search(2.5).key.should.be.equal 3
      t.search(3.5).key.should.be.equal 3
      t.search(4.5).key.should.be.equal 5
      t.search(5.5).key.should.be.equal 5
      t.search(6.5).key.should.be.equal 7
      t.search(7.5).key.should.be.equal 7

  describe 'in a tree containing the target value', ->
    t = new AVLTree(1, '1')
    t.insert(i, '' + i) for i in [2..7]

    for i in [1..7]
      do (i) ->
        describe "searching for #{i} in tree[1..7]", ->
          r = t.search(i)

          it 'should match the key', ->
            r.key.should.be.equal i
          it 'should match the value', ->
            r.value.should.be.equal ('' + i)

describe 'deletion', ->
  assert_is_invalid = (x) ->
    it 'should isolate deleted node', ->
      (x.parent?).should.be.equal false
      (x.left()?).should.be.equal false
      (x.right()?).should.be.equal false
    it 'should invalidate deleted node\'s key', ->
      (x.key?).should.be.equal false
    it 'should invalidate deleted node\'s value', ->
      (x.value?).should.be.equal false

  describe 'balanced', ->
    describe 'from a tree missing the deleted value', ->
      t = new AVLTree(0, '0')
      r = t.delete(2)

      it 'should return nil', ->
        (r?).should.be.equal false
      it 'should not alter the key', ->
        t.key.should.be.equal 0
      it 'should not alter the value', ->
        t.value.should.be.equal '0'
      it 'should not alter parent', ->
        (t.parent?).should.be.equal false
      it 'should not alter children', ->
        t.is_leaf().should.be.equal true

    describe 'from single node tree', ->
      t = new AVLTree(2, '2')
      r = t.delete(2)

      it 'should return value', ->
        r.should.be.equal '2'

      assert_is_invalid(t)

    describe 'from root[height = 1].left', ->
      t = new AVLTree(2, '2')
      t.insert(1, '1')
      x = t.left()
      r = t.delete(1)

      it 'should return value', ->
        r.should.be.equal '1'

      assert_is_invalid(x)

      it 'should update own height', ->
        t.height().should.be.equal 1
      it 'should update own balance', ->
        t.balance().should.be.equal 0

    describe 'from root[height = 1].right', ->
      t = new AVLTree(2, '2')
      t.insert(3, '3')
      x = t.right()
      r = t.delete(3)

      it 'should return the value', ->
        r.should.be.equal '3'

      assert_is_invalid(x)

      it 'should update own height', ->
        t.height().should.be.equal 1
      it 'should update own balance', ->
        t.balance().should.be.equal 0

  describe 'imbalanced', ->
    describe 'LL', ->
      t = new AVLTree(4, '4')
      t.insert(i) for i in [3, 2, 1]
      x = t
      t = t.root()
      r = t.delete(4)
      t = t.root()

      it 'should return the value', ->
        r.should.be.equal '4'

      assert_is_invalid(x)

      it 'should balance correctly', ->
        t.key.should.be.equal 2
        t.left().key.should.be.equal 1
        t.right().key.should.be.equal 3

    describe 'LR', ->
      t = new AVLTree(4, '4')
      t.insert(i) for i in [3, 1, 2]
      x = t
      t = t.root()
      r = t.delete(4)
      t = t.root()

      it 'should return the value', ->
        r.should.be.equal '4'

      assert_is_invalid(x)

      it 'should balance correctly', ->
        t.key.should.be.equal 2
        t.left().key.should.be.equal 1
        t.right().key.should.be.equal 3

    describe 'RR', ->
      t = new AVLTree(1, '1')
      t.insert(i) for i in [2, 3, 4]
      x = t
      t = t.root()
      r = t.delete(1)
      t = t.root()

      it 'should return the value', ->
        r.should.be.equal '1'

      assert_is_invalid(x)

      it 'should balance correctly', ->
        t.key.should.be.equal 3
        t.left().key.should.be.equal 2
        t.right().key.should.be.equal 4

    describe 'RL', ->
      t = new AVLTree(1, '1')
      t.insert(i) for i in [2, 4, 3]
      x = t
      t = t.root()
      r = t.delete(1)
      t = t.root()

      it 'should return the value', ->
        r.should.be.equal '1'

      assert_is_invalid(x)

      it 'should balance correctly', ->
        t.key.should.be.equal 3
        t.left().key.should.be.equal 2
        t.right().key.should.be.equal 4
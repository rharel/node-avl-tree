###
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
###

should = require 'should'

assert = require './helpers.test'
AVLTree = require '../lib/avl'

describe 'unit', ->
  describe 'initialization', ->
    describe 'default', ->
      t = new AVLTree

      assert.it_should_be_empty(t)

      it 'should have a simple comparator', ->
        t._comparator(3, 2).should.be.above 0
        t._comparator(2, 3).should.be.below 0
        t._comparator(3, 3).should.be.equal 0

    describe 'user arguments', ->
      comparator = (a, b) -> b - a
      t = new AVLTree(comparator)

      assert.it_should_be_empty(t)

      it 'should accept user comparator', ->
        t._comparator.should.be.equal comparator

  describe 'insertion', ->
    describe 'into an empty tree', ->
      t = new AVLTree
      a = t.insert(0, '0')

      assert.it_should_match_key_and_value(a, 0, '0')
      assert.it_should_be_the_root(a, t)
      assert.it_should_be_a_leaf(a)

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
      describe 'into left', ->
        t = new AVLTree
        a = t.insert(2, '2')
        b = t.insert(1, '1')

        assert.it_should_match_key_and_value(a, 2, '2')
        assert.it_should_be_the_root(a, t)
        assert.it_should_have_children(a, b, null)
        assert.it_should_have_props(a, 2, 1)

        assert.it_should_match_key_and_value(b, 1, '1')
        assert.it_should_be_a_leaf(b)

      describe 'into right', ->
        t = new AVLTree
        a = t.insert(1, '1')
        b = t.insert(2, '2')

        assert.it_should_match_key_and_value(a, 1, '1')
        assert.it_should_be_the_root(a, t)
        assert.it_should_have_children(a, null, b)
        assert.it_should_have_props(a, 2, -1)

        assert.it_should_match_key_and_value(b, 2, '2')
        assert.it_should_be_a_leaf(b)

    describe 'imbalanced', ->
      test_case = (name, x, y, z) ->
        describe name, ->
          t = new AVLTree
          [vx, vy, vz] = (('' + i) for i in [x, y, z])
          a = t.insert(x, vx)
          b = t.insert(y, vy)
          c = t.insert(z, vz)

          assert.it_should_match_key_and_value(a, x, vx)
          assert.it_should_match_key_and_value(b, y, vy)
          assert.it_should_match_key_and_value(c, z, vz)

          [L, root, R] = [a, b, c].sort((p, q) -> p.key - q.key)

          assert.it_should_be_the_root(root, t)
          assert.it_should_have_children(root, L, R)
          assert.it_should_have_props(root, 2, 0)

          assert.it_should_be_a_leaf(L)
          assert.it_should_be_a_leaf(R)

      test_case('LL', 3, 2, 1)
      test_case('LR', 3, 1, 2)
      test_case('RR', 1, 2, 3)
      test_case('RL', 1, 3, 2)

    describe 'verify structure after inserting [1..7]', ->
      t = new AVLTree
      result = (t.insert(i, '' + i) for i in [1..7])
      [LL, L, LR, root, RL, R, RR] = result

      assert.it_should_match_key_and_value(result[i - 1], i, '' + i) \
        for i in [1..7]

      assert.it_should_be_the_root(root, t)
      assert.it_should_have_children(root, L, R)
      assert.it_should_have_props(root, 3, 0)

      assert.it_should_have_children(L, LL, LR)
      assert.it_should_have_props(L, 2, 0)

      assert.it_should_have_children(R, RL, RR)
      assert.it_should_have_props(R, 2, 0)

      assert.it_should_be_a_leaf(node) for node in [LL, LR, RL, RR]

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
                assert.it_should_match_key_and_value(r, i, '' + i)

    describe 'in a tree containing the target value', ->
      t = new AVLTree
      t.insert(i, '' + i) for i in [1..7]

      for i in [1..7]
        do (i) ->
          describe "search(#{i})", ->
            r = t.search(i)
            assert.it_should_match_key_and_value(r, i, '' + i)

  describe 'deletion', ->

    describe 'in an empty tree', ->
      t = new AVLTree
      r = t.remove(0)

      it 'should return null', ->
        (r?).should.be.equal false

    describe 'from a tree missing the deleted value', ->
      t = new AVLTree
      a = t.insert(1, '1')
      r = t.remove(0)

      it 'should return null', ->
        (r?).should.be.equal false

    describe 'from single node tree by key', ->
      t = new AVLTree
      x = t.insert(1, '1')
      r = t.remove(1)

      it 'should return deleted node\'s value', ->
        r.should.be.equal '1'

      assert.it_should_be_invalid(x)
      assert.it_should_be_empty(t)

    describe 'from single node tree by node', ->
      t = new AVLTree
      x = t.insert(1, '1')
      r = x.remove()

      it 'should return deleted node\'s value', ->
        r.should.be.equal '1'

      assert.it_should_be_invalid(x)
      assert.it_should_be_empty(t)

    describe 'from tree by invalid node', ->
      t = new AVLTree
      x = t.insert(1, '1')
      b = t.insert(2, '2')
      x.remove()
      r = x.remove()

      it 'should return null', ->
        (r?).should.be.equal false

      assert.it_should_be_invalid(x)
      assert.it_should_be_the_root(b, t)
      assert.it_should_be_a_leaf(b)

    describe 'balanced', ->
      describe 'from tree.length == 2', ->
        test_case = (name, x, y, delete_root) ->
          describe name, ->
            t = new AVLTree
            a = t.insert(x, '' + x)
            b = t.insert(y, '' + y)
            d_key = if delete_root then x else y
            d_value = '' + d_key
            d_node = if delete_root then a else b
            r = t.remove(d_key)

            it 'should return deleted node\'s value', ->
              r.should.be.equal d_value

            root = if delete_root then b else a
            assert.it_should_be_invalid(d_node)
            assert.it_should_be_the_root(root, t)
            assert.it_should_be_a_leaf(root)

        test_case('from root --> L deleting L', 2, 1, false)
        test_case('from root --> L deleting root', 2, 1, true)
        test_case('from root --> R deleting R', 1, 2, false)
        test_case('from root --> R deleting root', 1, 2, true)

      describe 'from tree.length == 3 deleting root', ->
        t = new AVLTree
        a = t.insert(1, '1')
        x = t.insert(2, '2')
        b = t.insert(3, '3')
        r = t.remove(2)

        it 'should return deleted node\'s value', ->
          r.should.be.equal '2'

        assert.it_should_be_invalid(x)
        assert.it_should_be_the_root(a, t)
        assert.it_should_have_children(a, null, b)
        assert.it_should_be_a_leaf(b)

    describe 'imbalanced', ->
      describe 'LL', ->
        t = new AVLTree
        [x, R, root, L] = (t.insert(i, '' + i) for i in [4, 3, 2, 1])
        r = t.remove(4)

        it 'should return deleted node\'s value', ->
          r.should.be.equal '4'

        assert.it_should_be_invalid(x)

        assert.it_should_be_the_root(root, t)
        assert.it_should_have_children(root, L, R)
        assert.it_should_have_props(root, 2, 0)

        assert.it_should_be_a_leaf(L)
        assert.it_should_be_a_leaf(R)

      describe 'RR', ->
        t = new AVLTree
        [x, L, root, R] = (t.insert(i, '' + i) for i in [1, 2, 3, 4])
        r = t.remove(1)

        it 'should return deleted node\'s value', ->
          r.should.be.equal '1'

        assert.it_should_be_invalid(x)

        assert.it_should_be_the_root(root, t)
        assert.it_should_have_children(root, L, R)
        assert.it_should_have_props(root, 2, 0)

        assert.it_should_be_a_leaf(L)
        assert.it_should_be_a_leaf(R)

      describe 'RL', ->
        t = new AVLTree
        [x, L, R, root] = (t.insert(i, '' + i) for i in [1, 2, 4, 3])
        r = t.remove(1)

        it 'should return deleted node\'s value', ->
          r.should.be.equal '1'

        assert.it_should_be_invalid(x)

        assert.it_should_be_the_root(root, t)
        assert.it_should_have_children(root, L, R)
        assert.it_should_have_props(root, 2, 0)

        assert.it_should_be_a_leaf(L)
        assert.it_should_be_a_leaf(R)

      describe 'LR', ->
        t = new AVLTree
        [x, R, L, root] = (t.insert(i, '' + i) for i in [4, 3, 1, 2])
        r = t.remove(4)

        it 'should return deleted node\'s value', ->
          r.should.be.equal '4'

        assert.it_should_be_invalid(x)

        assert.it_should_be_the_root(root, t)
        assert.it_should_have_children(root, L, R)
        assert.it_should_have_props(root, 2, 0)

        assert.it_should_be_a_leaf(L)
        assert.it_should_be_a_leaf(R)

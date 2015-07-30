###
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
###

###
  Naming Convention Used
  ======================

  Any object, method, or argument whose name begins with an _underscore
  is to be considered a private implementation detail.
###

_left = 0
_right = 1
_sibling = (i) -> 1 - i
_swap = (a, b, p) ->
  tmp = a[p]
  a[p] = b[p]
  b[p] = tmp

###
  AVL-nodes are the building block of the tree. Each node is identified by
  its key and value. The key is used to dictate an ordering among nodes.
  The value is an easy way for users of the tree to tie their own data to a
  node.

  You can query nodes for their properties as well as use them to traverse
  the tree. The root node yields null when queried for its parent and
  nodes with less than two children will yield null when queried for
  a missing child.
###
class AVLNode
  constructor: (@_tree, @key, @value = null) ->
    @parent = null
    @_children = [null, null]
    @_height = 1
    @_balance = 0

  left: -> @_children[_left]
  right: -> @_children[_right]
  height: -> @_height
  balance: -> @_balance

  is_root: -> !@parent?
  is_leaf: -> !@left()? and !@right()?
  is_invalid: -> !@_tree?

  _is_balanced: -> Math.abs(@_balance) < 2

  _debug_string: ->
    s = ''
    if @left()?
      s += @key + ' --L--> ' + @left().key + '\n'
      s += @left()._debug_string()
    if @right()?
      s += @key + ' --R--> ' + @right().key + '\n'
      s += @right()._debug_string()
    return s

  _invalidate: ->
    @parent = null
    @_children[_left] = null
    @_children[_right] = null
    @key = null
    @value = null
    @_tree = null

  _update: ->
    h_left = if @left()? then @left()._height else 0
    h_right = if @right()? then @right()._height else 0
    @_height = 1 + Math.max(h_left, h_right)
    @_balance = h_left - h_right

  _swap_parent: (other) ->
    _swap(this, other, 'parent')
    if this.parent is this then this.parent = other
    if other.parent is other then other.parent = this

  _swap_children: (other) ->
    _swap(this, other, '_children')
    for x in [[this, other], [other, this]]
      do ->
        [a, b] = x
        for i in [_left, _right]
          do ->
            if a._children[i] is a
              a._children[i] = b
            else
              a._children[i]?.parent = a

  _swap: (other) ->
    if other is this
      return
    @_swap_parent(other)
    @_swap_children(other)
    _swap(this, other, '_height')
    _swap(this, other, '_balance')

  _index_of: (c) ->
    if @left() is c
      return _left
    else if @right() is c
      return _right
    else
      return null

  _connect_child: (c, i) ->
    @_children[i] = c
    if c?
      c.parent = this
    @_update()

  ###
    @brief
      Performs either a left-left (LL) or right-right (RR) rotation.

    @param  i   _left for LL, _right for RR

    @details
      Restores balance to a chain of same-side nodes starting at 'this' node.

      @example
        For the LL case:
        Let this node be 'a', a.left be 'b', and b.left be 'c', then a _left
        XX rotation will transform (1) to (2):
        (1)       |(2)
             a    |       b
            / \   |      / \
           b  aR  |    c     a
          / \     |   / \   / \
         c   z    |  cL cR z  aR
        / \       |
       cL cR      |
  ###
  _rotate_XX: (i) ->
    j = _sibling(i)
    a = this; b = a._children[i]; p = a.parent

    a._connect_child(b._children[j], i)
    b._connect_child(a, j)
    if p?
      p._connect_child(b, p._index_of(a))
    else
      b.parent = null

  ###
    @brief
      Performs either a left-right (LR) or right-left (RL) rotation.

    @param  i   _left for LR, _right for RL

    @details
      Transforms either an LR-imbalance to an LL one, or a RL-imbalance to
      an RR one. @see _rotate_XX()

      @example
        For the LR case:
        Let this node be 'a', a.left be 'b', and b.right be 'c', then a _left
        XY rotation will transform (1) to (2):
        (1)        |(2)
             a     |        a
            / \    |       / \
           b   aR  |      c  aR
          / \      |     / \
         bL  c     |    b  cR
            / \    |   / \
           cL cR   |  bL cL
  ###
  _rotate_XY: (i) ->
    j = _sibling(i)
    a = this; b = a._children[i]; c = b._children[j]

    b._connect_child(c._children[i], j)
    c._connect_child(b, i)
    a._connect_child(c, i)

  ###
    Removes the node from the tree and returns its value or null
    if the node is invalid (i.e. it was already removed).
    @see AVLTree.remove()
  ###
  remove: ->
    if @is_invalid()
      return null
    else
      return @_tree._remove_node(this)



###
  The AVL-tree is the interface with which the user manipulates the tree
  structure.

  The three principal operations available are: insertion, removal, and query.
  The initial tree directly after instantiation will be empty and have a
  null root. New nodes can then be inserted and the tree will sort them
  according to their keys. The ordering is defined by the comparator used.

  The default comparator assumes keys are numbers and imposes an ascending
  order. User made comparators can be supplied during instantiation.
  A comparator is a function taking two keys A and B, and that returns
  a positive number when A > B, a negative number when A < B, and zero when
  A == B.
###
class AVLTree
  constructor: (comparator = ((a, b) -> a - b)) ->
    @_comparator = comparator
    @root = null

  _restore_balance: (n) ->
    n._update()
    until (n.is_root() and n._is_balanced())
      if n._balance is 2
        if n.left()._balance is -1
          n._rotate_XY(_left)
        n._rotate_XX(_left)
      else if n._balance is -2
        if n.right()._balance is 1
          n._rotate_XY(_right)
        n._rotate_XX(_right)

      if !n.is_root()
        n = n.parent
        n._update()

    @root = n

  is_empty: -> !@root?

  ###
    Traverses down the tree in search of a node with the given key,
    if none is found, yields the last node visited or null if the tree
    is empty.
  ###
  search: (key) ->
    if @is_empty()
      return null

    n = @root
    q = null
    while n?
      q = n
      c = @_comparator(q.key, key)
      if c is 0
        return q
      else if c > 0
        n = n.left()
      else
        n = n.right()

    return q

  ###
    Inserts a new node with given key and value into the tree and returns
    a reference to the newly created node or null if a node with an equal
    key already exists.

    The reference to the inserted node remains valid until the node is removed.
    A removed node becomes invalid, and has all its properties (including
    its key and value) be set to null.
  ###
  insert: (key, value = null) ->
    if @is_empty()
      return @root = new AVLNode(this, key, value)

    x = @search(key)
    c = @_comparator(x.key, key)
    if c is 0
      return null
    else
      n = new AVLNode(this, key, value)
      x._connect_child(n, if c > 0 then _left else _right)
      @_restore_balance(x)
      return n

  _remove_node: (x) ->
    if x.left()? and x.right()?
      subtree = new AVLTree(@_comparator)
      subtree.root = x.left()
      y = subtree.search(x.key)
      x._swap(y)

    if !x.is_root()
      i = x.parent._index_of(x)
      if x.left()?
        x.parent._connect_child(x.left(), i)
      else
        x.parent._connect_child(x.right(), i)
      @_restore_balance(x.parent)
    else
      if x.left()?
        @root = x.left()
        x.left().parent = null
      else
        @root = x.right()
        x.right()?.parent = null

    v = x.value
    x._invalidate()
    return v

  ###
    Removes a node with given key from the tree and returns its value
    or null if no such node exists.

    Any reference to a removed node becomes invalid. An invalid node has all
    its properties (including its key and value) be set to null.

    You may also remove a node directly, @see AVLNode.remove()
  ###
  remove: (key) ->
    if @is_empty()
      return null
    x = @search(key)
    c = @_comparator(x.key, key)
    if c isnt 0
      return null
    else
      return @_remove_node(x)


root = this
if module?.exports?
  module.exports = AVLTree
root.AVLTree = AVLTree

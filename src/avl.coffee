_left = 0
_right = 1
_sibling = (i) -> 1 - i
_swap = (a, b) -> b = [a, a = b][0]

class AVLNode
  constructor: (@key = 0, @value = null) ->
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

  _update: ->
    h_left = if @left()? then @left()._height else 0
    h_right = if @right()? then @right()._height else 0
    @_height = 1 + Math.max(h_left, h_right)
    @_balance = h_left - h_right

  _swap_relatives: (other) ->
    if other isnt this
      _swap(@parent, other.parent)
      _swap(@_children, other._children)
      _swap(@_height, other._height)
      _swap(@_balance, other._balance)

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

  _rotate_XX: (i) ->
    j = _sibling(i)
    a = this; b = a._children[i]; p = a.parent

    a._connect_child(b._children[j], i)
    b._connect_child(a, j)
    if p?
      p._connect_child(b, p._index_of(a))
    else
      b.parent = null

  _rotate_XY: (i) ->
    j = _sibling(i)
    a = this; b = a._children[i]; c = b._children[j]

    b._connect_child(c._children[i], j)
    c._connect_child(b, i)
    a._connect_child(c, i)


class AVLTree
  constructor: (comparator = ((a, b) -> a - b)) ->
     @_comparator = comparator
     @_root = null

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

    @_root = n

  is_empty: -> !@_root?

  search: (key) ->
    if @is_empty()
      return null

    n = @_root
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

  insert: (key, value = null) ->
    if @is_empty()
      return @_root = new AVLNode(key, value)

    x = @search(key)
    c = @_comparator(x.key, key)
    if c is 0
      return null
    else
      n = new AVLNode(key, value)
      x._connect_child(n, if c > 0 then _left else _right)
      @_restore_balance(x)
      return n

  delete: (key) ->
    if @is_empty()
      return null

    x = @search(key)
    c = @_comparator(x.key, key)
    if c isnt 0
      return null
    else if x.left()? and x.right()?
      subtree = new AVLTree(@_comparator);
      subtree._root = x.left()
      y = subtree.search(x.key)
      x._swap_relatives(y)
      y._update()

    if !x.is_root()
      if x.left()?
        x.parent._connect_child(x.left(), _right)
      else
        x.parent._connect_child(null, x.parent._index_of(x))

    if x.parent?
      @_restore_balance(x.parent)

    v = x.value
    x._invalidate()
    return v


module.exports = AVLTree
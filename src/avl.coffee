_left = 0
_right = 1
_sibling = (i) -> 1 - i
_swap = (a, b) -> b = [a, a = b][0]

class AVLTree
  constructor:
    (@key = 0,
     @value = null,
     @comparator = ((a, b) -> a - b)) ->
       @parent = null
       @_children = [null, null]
       @_height = 1
       @_balance = 0

  left: -> @_children[_left]
  right: -> @_children[_right]
  root: -> if @is_root() then this else @parent.root()
  height: -> @_height
  balance: -> @_balance

  is_root: -> !@parent?
  is_leaf: -> !@left()? and !@right()?

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
    ex_c = @_children[i]
    @_children[i] = c
    if c?
      ex_p = c.parent
      c.parent = this

    @_update()
    return [ex_c, ex_p]

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

  _restore_balance: ->
    if @_balance is 2
      if @left()._balance is -1
        @_rotate_XY(_left)
      @_rotate_XX(_left)
    else if @_balance is -2
      if @right()._balance is 1
        @_rotate_XY(_right)
      @_rotate_XX(_right)

  _restore_balance_recursively: ->
    @_update()
    @_restore_balance()
    @parent?._restore_balance_recursively()

  search: (key) -> return @root().search_(key)
  search_: (key) ->
    c = @comparator(@key, key)
    if c is 0 or
      (c > 0 and !@left()?) or
      (c < 0 and !@right()?)
        return this
    else if c > 0
      return @left().search_(key)
    else
      return @right().search_(key)

  insert: (key, value = null) -> return @root().insert_(key, value)
  insert_: (key, value = null) ->
    x = @search_(key)
    c = @comparator(x.key, key)
    if c is 0
      return null

    n = new AVLTree(key, value, @comparator)
    x._connect_child(n, if c > 0 then _left else _right)
    x._restore_balance_recursively()

    return n

  delete: (key) -> return @root().delete_(key)
  delete_: (key) ->
    x = @search_(key)
    c = @comparator(x.key, key)
    if c isnt 0
      return null
    else if x.left()? and x.right()?
      y = x.left().search_(@key)
      x._swap_relatives(y)
      y._update()

    if !x.is_root()
      if x.left()?
        x.parent._connect_child(x.left(), _right)
      else
        x.parent._children[x.parent._index_of(x)] = null

    x.parent?._restore_balance_recursively()

    v = x.value
    x._invalidate()
    return v


module.exports = AVLTree
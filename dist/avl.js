
/*
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
 */


/*
  Naming Convention Used
  ======================

  Any object, method, or argument whose name begins with an _underscore
  is to be considered a private implementation detail.
 */

(function() {
  var AVLNode, AVLTree, _left, _right, _sibling, _swap, root;

  _left = 0;

  _right = 1;

  _sibling = function(i) {
    return 1 - i;
  };

  _swap = function(a, b, p) {
    var tmp;
    tmp = a[p];
    a[p] = b[p];
    return b[p] = tmp;
  };


  /*
    AVL-nodes are the building block of the tree. Each node is identified by
    its key and value. The key is used to dictate an ordering among nodes.
    The value is an easy way for users of the tree to tie their own data to a
    node.
  
    You can query nodes for their properties as well as use them to traverse
    the tree. The root node yields null when queried for its parent and
    nodes with less than two children will yield null when queried for
    a missing child.
   */

  AVLNode = (function() {
    function AVLNode(_tree, key1, value1) {
      this._tree = _tree;
      this.key = key1;
      this.value = value1 != null ? value1 : null;
      this.parent = null;
      this._children = [null, null];
      this._height = 1;
      this._balance = 0;
    }

    AVLNode.prototype.left = function() {
      return this._children[_left];
    };

    AVLNode.prototype.right = function() {
      return this._children[_right];
    };

    AVLNode.prototype.height = function() {
      return this._height;
    };

    AVLNode.prototype.balance = function() {
      return this._balance;
    };

    AVLNode.prototype.is_root = function() {
      return this.parent == null;
    };

    AVLNode.prototype.is_leaf = function() {
      return (this.left() == null) && (this.right() == null);
    };

    AVLNode.prototype.is_invalid = function() {
      return this._tree == null;
    };

    AVLNode.prototype._is_balanced = function() {
      return Math.abs(this._balance) < 2;
    };

    AVLNode.prototype._debug_string = function() {
      var s;
      s = '';
      if (this.left() != null) {
        s += this.key + ' --L--> ' + this.left().key + '\n';
        s += this.left()._debug_string();
      }
      if (this.right() != null) {
        s += this.key + ' --R--> ' + this.right().key + '\n';
        s += this.right()._debug_string();
      }
      return s;
    };

    AVLNode.prototype._invalidate = function() {
      this.parent = null;
      this._children[_left] = null;
      this._children[_right] = null;
      this.key = null;
      this.value = null;
      return this._tree = null;
    };

    AVLNode.prototype._update = function() {
      var h_left, h_right;
      h_left = this.left() != null ? this.left()._height : 0;
      h_right = this.right() != null ? this.right()._height : 0;
      this._height = 1 + Math.max(h_left, h_right);
      return this._balance = h_left - h_right;
    };

    AVLNode.prototype._swap_parent = function(other) {
      _swap(this, other, 'parent');
      if (this.parent === this) {
        this.parent = other;
      }
      if (other.parent === other) {
        return other.parent = this;
      }
    };

    AVLNode.prototype._swap_children = function(other) {
      var k, len, ref, results, x;
      _swap(this, other, '_children');
      ref = [[this, other], [other, this]];
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        x = ref[k];
        results.push((function() {
          var a, b, i, l, len1, ref1, results1;
          a = x[0], b = x[1];
          ref1 = [_left, _right];
          results1 = [];
          for (l = 0, len1 = ref1.length; l < len1; l++) {
            i = ref1[l];
            results1.push((function() {
              var ref2;
              if (a._children[i] === a) {
                return a._children[i] = b;
              } else {
                return (ref2 = a._children[i]) != null ? ref2.parent = a : void 0;
              }
            })());
          }
          return results1;
        })());
      }
      return results;
    };

    AVLNode.prototype._swap = function(other) {
      if (other === this) {
        return;
      }
      this._swap_parent(other);
      this._swap_children(other);
      _swap(this, other, '_height');
      return _swap(this, other, '_balance');
    };

    AVLNode.prototype._index_of = function(c) {
      if (this.left() === c) {
        return _left;
      } else if (this.right() === c) {
        return _right;
      } else {
        return null;
      }
    };

    AVLNode.prototype._connect_child = function(c, i) {
      this._children[i] = c;
      if (c != null) {
        c.parent = this;
      }
      return this._update();
    };


    /*
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
     */

    AVLNode.prototype._rotate_XX = function(i) {
      var a, b, j, p;
      j = _sibling(i);
      a = this;
      b = a._children[i];
      p = a.parent;
      a._connect_child(b._children[j], i);
      b._connect_child(a, j);
      if (p != null) {
        return p._connect_child(b, p._index_of(a));
      } else {
        return b.parent = null;
      }
    };


    /*
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
     */

    AVLNode.prototype._rotate_XY = function(i) {
      var a, b, c, j;
      j = _sibling(i);
      a = this;
      b = a._children[i];
      c = b._children[j];
      b._connect_child(c._children[i], j);
      c._connect_child(b, i);
      return a._connect_child(c, i);
    };


    /*
      Removes the node from the tree and returns its value or null
      if the node is invalid (i.e. it was already removed).
      @see AVLTree.remove()
     */

    AVLNode.prototype.remove = function() {
      if (this.is_invalid()) {
        return null;
      } else {
        return this._tree._remove_node(this);
      }
    };

    return AVLNode;

  })();


  /*
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
   */

  AVLTree = (function() {
    function AVLTree(comparator) {
      if (comparator == null) {
        comparator = (function(a, b) {
          return a - b;
        });
      }
      this._comparator = comparator;
      this.root = null;
    }

    AVLTree.prototype._restore_balance = function(n) {
      n._update();
      while (!(n.is_root() && n._is_balanced())) {
        if (n._balance === 2) {
          if (n.left()._balance === -1) {
            n._rotate_XY(_left);
          }
          n._rotate_XX(_left);
        } else if (n._balance === -2) {
          if (n.right()._balance === 1) {
            n._rotate_XY(_right);
          }
          n._rotate_XX(_right);
        }
        if (!n.is_root()) {
          n = n.parent;
          n._update();
        }
      }
      return this.root = n;
    };

    AVLTree.prototype.is_empty = function() {
      return this.root == null;
    };


    /*
      Traverses down the tree in search of a node with the given key,
      if none is found, yields the last node visited or null if the tree
      is empty.
     */

    AVLTree.prototype.search = function(key) {
      var c, n, q;
      if (this.is_empty()) {
        return null;
      }
      n = this.root;
      q = null;
      while (n != null) {
        q = n;
        c = this._comparator(q.key, key);
        if (c === 0) {
          return q;
        } else if (c > 0) {
          n = n.left();
        } else {
          n = n.right();
        }
      }
      return q;
    };


    /*
      Inserts a new node with given key and value into the tree and returns
      a reference to the newly created node or null if a node with an equal
      key already exists.
    
      The reference to the inserted node remains valid until the node is removed.
      A removed node becomes invalid, and has all its properties (including
      its key and value) be set to null.
     */

    AVLTree.prototype.insert = function(key, value) {
      var c, n, x;
      if (value == null) {
        value = null;
      }
      if (this.is_empty()) {
        return this.root = new AVLNode(this, key, value);
      }
      x = this.search(key);
      c = this._comparator(x.key, key);
      if (c === 0) {
        return null;
      } else {
        n = new AVLNode(this, key, value);
        x._connect_child(n, c > 0 ? _left : _right);
        this._restore_balance(x);
        return n;
      }
    };

    AVLTree.prototype._remove_node = function(x) {
      var i, ref, subtree, v, y;
      if ((x.left() != null) && (x.right() != null)) {
        subtree = new AVLTree(this._comparator);
        subtree.root = x.left();
        y = subtree.search(x.key);
        x._swap(y);
      }
      if (!x.is_root()) {
        i = x.parent._index_of(x);
        if (x.left() != null) {
          x.parent._connect_child(x.left(), i);
        } else {
          x.parent._connect_child(x.right(), i);
        }
        this._restore_balance(x.parent);
      } else {
        if (x.left() != null) {
          this.root = x.left();
          x.left().parent = null;
        } else {
          this.root = x.right();
          if ((ref = x.right()) != null) {
            ref.parent = null;
          }
        }
      }
      v = x.value;
      x._invalidate();
      return v;
    };


    /*
      Removes a node with given key from the tree and returns its value
      or null if no such node exists.
    
      Any reference to a removed node becomes invalid. An invalid node has all
      its properties (including its key and value) be set to null.
    
      You may also remove a node directly, @see AVLNode.remove()
     */

    AVLTree.prototype.remove = function(key) {
      var c, x;
      if (this.is_empty()) {
        return null;
      }
      x = this.search(key);
      c = this._comparator(x.key, key);
      if (c !== 0) {
        return null;
      } else {
        return this._remove_node(x);
      }
    };

    return AVLTree;

  })();

  root = this;

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = AVLTree;
  }

  root.AVLTree = AVLTree;

}).call(this);

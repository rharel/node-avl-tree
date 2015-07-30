[![NPM Version](https://badge.fury.io/js/node-avl-tree.png)](https://npmjs.org/package/node-avl-tree)
[![Build Status](https://travis-ci.org/rharel/node-avl-tree.svg)](https://travis-ci.org/rharel/node-avl-tree)
[![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com)

## Installation

Install via npm: `npm install node-avl-tree`

The `dist/` directory contains both a normal (`avl.js`) as well as a minified version of the library (`avl.min.js`).
Import either into Node.js using `require("avl")` or directly include in the browser using `<script src="avl.min.js"></script>`

## Usage

### Create
```javascript
var t = new AVLTree();
t.is_empty();  // true
t.root;  // null
```

### Insert
```javascript
var t = new AVLTree();
var k = 1;  // Key is used to determine order
var v = 'hello';  // User data to be associated with key
var n = t.insert(k, v);  // returns newly created AVLNode
n.key;  // k
n.value;  // v
t.root;  // n
```

### Search
```javascript
var t = new AVLTree();
var a = t.insert(1, 'hello');
var b = t.insert(2, 'world');
t.search(1);  // returns a
t.search(3);  // returns b, the last leaf visited while searching for 3
```

### Remove
```javascript
var t = new AVLTree();
var a = t.insert(1, 'hello');
var b = t.insert(2, 'world');

a.is_valid();  // true
t.remove(1);  // Removal by key, returns 'hello'
a.is_valid();  // false, node has been removed

b.is_valid();  // true
b.remove();  // Removal by node, returns 'world'
b.is_valid();  // false, node has been removed
```

### Custom Comparator
The default tree will assume its keys are numbers and imposes the natural
ordering on its nodes based on them. You may supply your own compare function
during instantiation to customize this behavior.

```javascript
var default = function(a, b) { return a - b; }  // This is the default comparator
var reversed = function(a, b) { return b - a; }

var t1 = new AVLTree();  // == new AVLTree(default)
t1.insert(1); t1.insert(2); t1.insert(3);

/*
 * Tree structure:
 *    2
 *   / \
 *  1   3
 */

var t2 = new AVLTree(reversed);
t2.insert(1); t2.insert(2); t2.insert(3);

/*
 * Tree structure:
 *    2
 *   / \
 *  3   1
 */
```

### Example: Sorting
```javascript
var t = new AVLTree();
t.insert(2, 'world');
t.insert(6, 'day');
t.insert(5, 'beautiful');
t.insert(3, 'what');
t.insert(1, 'hello');
t.insert(4, 'a');

result = []
while (!t.is_empty()) {
    result.push(t.search(0).remove());
}

result.join()  // 'hello world what a beautiful day'
```

## License

This software is licensed under the **MIT License**. See the [LICENSE](LICENSE.txt) file for more information.

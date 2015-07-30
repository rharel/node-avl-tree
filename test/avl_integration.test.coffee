###
  @author Raoul Harel
  @license The MIT license (../LICENSE.txt)
  @copyright 2015 Raoul Harel
  @url rharel/node-avl-tree on GitHub
###

should = require 'should'
shuffle = require 'shuffle-array'

assert = require './helpers.test'
AVLTree = require '../lib/avl'

describe 'integration', ->
  describe 'sorting', ->
    test_case = (name, comparator, sorted, query) ->
      describe name, ->
        verbose = false
        t = new AVLTree(comparator)
        sorted = [1..100]
        shuffled = shuffle(sorted, {'copy': true})
        t.insert(i, i) for i in shuffled

        if verbose then console.log('input: ' + shuffled)
        result = []
        until t.is_empty()
          if verbose then console.log(t.root._debug_string() + '***')
          result.push(t.search(query).remove())
        if verbose then console.log('output: ' + result)

        assert.it_should_be_empty(t)
        it 'should return sorted output', ->
          assert.arrays_are_equal(result, sorted)

    test_case(
      'ascending with comparator(a - b)', ((a, b) -> a - b), [1..100], 0)
    test_case(
      'descending with comparator(a - b)', ((a, b) -> a - b), [100..1], 101)
    test_case(
      'ascending with comparator(b - a)', ((a, b) -> b - a), [100..1], 0)
    test_case(
      'descending with comparator(b - a)', ((a, b) -> b - a), [1..100], 101)

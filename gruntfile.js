/*
 @author Raoul Harel
 @license The MIT license (LICENSE.txt)
 @copyright 2015 Raoul Harel
 @url rharel/node-avl-tree on GitHub
*/

module.exports = function(grunt) {

  config = {
    pkg: grunt.file.readJSON('package.json'),
    lib_dir: 'lib/',
    test_dir: 'test/',
    dist_dir: 'dist/',
    source_files: [ '<%= lib_dir %>**/*.coffee' ],
    test_files: '<%= test_dir %>**/*.test.coffee',

    coffeelint: {
      options: {
        configFile: 'coffeelint.json'
      },
      all: ['<%= source_files %>', '<%= test_files %>']
    }
  };

  require('load-grunt-tasks')(grunt);

  grunt.registerTask('lint', ['coffeelint']);

  return grunt.initConfig(config);
};
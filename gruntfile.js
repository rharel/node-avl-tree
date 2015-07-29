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
    },

    coffee: {
      dev: {
        options: {
          sourceMap: true
        },
        files: [
          {
            expand: true,
            src: ['<%= source_files %>'],
            ext: '.js'
          },
          {
            expand: true,
            src: ['<%= test_files %>'],
            ext: '.js'
          }
        ]
      },
      release: {
        files: {
          '<%= dist_dir %>/avl.js': '<%= lib_dir %>/avl.coffee'
        }
      }
    }
  };

  require('load-grunt-tasks')(grunt);

  return grunt.initConfig(config);
};
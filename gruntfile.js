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

    clean: {
      all: {
        src: [
          '<%= lib_dir %>**/*.js',
          '<%= lib_dir %>**/*.js.map',
          '<%= test_dir %>**/*.js',
          '<%= test_dir %>**/*.js.map',
          '<%= dist_dir %>**/*.js',
          '<%= dist_dir %>**/*.js.map'
        ]
      }
    },

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
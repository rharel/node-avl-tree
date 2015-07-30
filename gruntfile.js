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
      dev: {
        src: [
          '<%= lib_dir %>**/*.js',
          '<%= lib_dir %>**/*.js.map',
          '<%= test_dir %>**/*.js',
          '<%= test_dir %>**/*.js.map'
        ]
      },
      release: {
        src: [
          '<%= dist_dir %>**/*.js',
          '<%= dist_dir %>**/*.js.map'
        ]
      },
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
            ext: '.test.js'
          }
        ]
      },
      release: {
        files: {
          '<%= dist_dir %>/avl.js': '<%= lib_dir %>/avl.coffee'
        }
      }
    },

    mochacli: {
      options: {
        require: ['should'],
        reporter: 'spec',
        bail: true
      },
      unit: ['<%= test_dir %>/avl_unit.test.js'],
      integration: ['<%= test_dir %>/avl_integration.test.js'],
      all: [
        '<%= test_dir %>/avl_unit.test.js',
        '<%= test_dir %>/avl_integration.test.js'
      ]
    },

    uglify: {
      release: {
        files: {
          '<%= dist_dir %>/avl.min.js': ['<%= dist_dir %>/avl.js']
        }
      }
    }
  };

  grunt.registerTask('build', [
    'clean:dev',
    'coffee:dev'
  ]);
  grunt.registerTask('test', ['mochacli:all']);
  grunt.registerTask('dev', [
    'coffeelint:all',
    'clean:dev',
    'coffee:dev',
    'mochacli:all'
  ]);
  grunt.registerTask('release', [
    'coffeelint:all',
    'clean:release',
    'coffee:release',
    'uglify:release'
  ]);
  grunt.registerTask('default', 'dev');

  require('load-grunt-tasks')(grunt);

  return grunt.initConfig(config);
};
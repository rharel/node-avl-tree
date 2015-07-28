/*
Raoul\voronoi-art

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Raoul Harel <raoulhaa@gmail.com>
@copyright  2015 Raoul Harel
@link       http://www.rharel.com
@license    http://choosealicense.com/licenses/MIT  MIT License
*/
module.exports = function(grunt) {

  /* ALIASES */
  var config, define, jsonFile, log;
  jsonFile = grunt.file.readJSON;
  define = grunt.registerTask;
  log = grunt.log.writeln;

  /* GRUNT CONFIGURATION */
  config = {
    srcDir: 'src/',
    tstDir: 'test/',
    docDir: 'docs/',
    resDir: 'res/',
    srcFiles: ['<%= srcDir %>**/*.coffee', 'index.coffee'],
    tstFiles: '<%= tstDir %>**/*.test.coffee',
    pkg: jsonFile('package.json'),

/* TASKS DEFINITION */
watch: {
  options: {
    tasks: ['lint', 'coffee'],
    interrupt: true,
    atBegin: true,
    dateFormat: function(time) {
return log("Done in " + time + "ms");
}
},
gruntfile: {
  files: 'gruntfile.coffee',
  tasks: '<%= watch.options.tasks %>'
},
project: {
  files: ['<%= srcFiles %>', '<%= tstFiles %>'],
  tasks: '<%= watch.options.tasks %>'
}
},
coffeelint: {
  options: jsonFile('coffeelint.json'),
  project: ['<%= srcFiles %>', '<%= tstFiles %>']
},
mochacli: {
  options: {
    reporter: 'spec',
    require: ['should'],
    compilers: ['coffee:coffee-script/register']
  },
  project: {
    src: ['<%= tstFiles %>']
  }
},
codo: {
  options: {
    title: 'voronoi-art',
    debug: false,
    inputs: ['<%= srcDir %>'],
    output: '<%= docDir %>'
  }
},
coffee: {
  build: {
    expand: true,
    ext: '.js',
    src: '<%= srcFiles %>',
    dest: '<%= libDir %>'
  }
},
uglify: {
  build: {
    files: [
      {
        expand: true,
        src: '<%= srcDir %>**/*.js'
      }
    ]
  }
},
clean: {
  build: ['<%= srcDir %>**/*.js', 'index.js'],
  docs: ['<%= docDir %>']
}
};

/* CUSTOM FUNCTIONS */

/* GRUNT MODULES */
require('load-grunt-tasks')(grunt);

/* GRUNT TASKS */
define('lint', ['coffeelint']);
define('test', ['mochacli']);
define('docs', ['codo']);
define('coffee', ['coffee:build']);
define('build:dev', ['clean:build', 'lint', 'test', 'coffee:build']);
define('build', ['build:dev', 'uglify:build']);
define('default', ['build']);
return grunt.initConfig(config);
};
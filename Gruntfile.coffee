# build configuration

module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      build:
        expand: yes
        flatten: no
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    replace:
      version:
        src: ['lib/metrics/versions.js']
        overwrite: yes
        replacements: [
          from: "[%STATS_VERSION%]"
          to: "<%= pkg.version %>"
        ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.registerTask 'default', ['coffee', 'replace']

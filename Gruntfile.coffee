config =
	testCodeDirectory: __dirname + '/test/'
	testServerPath: 'test/server/server.coffee'
	testServerPort: 7777


module.exports = (grunt) ->

	#	Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		banner   : '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
			'<%= grunt.template.today("yyyy-mm-dd") %>\n' +
			'<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
			'* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %> @ <%= pkg.company.name%>' +
			' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'

		clean:
			build: ['dist/*']
			test:  ['test/js/*']

		coffee:
			default:
				expand: true
				flatten: true
				cwd: ''
				src: ['src/*.coffee']
				dest: 'dist/'
				ext: '.js'

		# Task Configuration
		copy:
			dev:
				files: [{expand:true, flatten:true, src:['dist/b_dropdown.js'], dest: 'test/js/'}]

		concurrent:
			dev:
				tasks: ['nodemon', 'watch']
				options:
					logConcurrentOutput: true

		nodemon:
			dev:
				script: 'test/server/server.coffee'
				options:
					env:
						PORT: config.testServerPort
						DIRECTORY: config.testCodeDirectory
					watch: ['test/server']

		uglify:
			options:
				banner: '<%= banner %>'

			dist:
				src: 'dist/b_dropdown.js'
				dest: 'dist/b_dropdown.min.js'

		watch:
			script:
				files: ['src/**/*.coffee']
				tasks: ['clean:test', 'build:dev', 'copy:dev']


	# These plugins provide necessary tasks.
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-concurrent'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-nodemon'
	grunt.loadNpmTasks 'grunt-contrib-uglify'

	grunt.registerTask 'build', (buildMode) ->

		grunt.task.run ['clean:build']
		grunt.task.run ['coffee']

		if not buildMode or buildMode is 'prod'
			grunt.task.run ['uglify']


	grunt.registerTask 'dev', ['clean:test', 'build:dev', 'copy:dev', 'concurrent:dev']
	grunt.registerTask 'release', ['build']
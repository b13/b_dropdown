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
			release: ['dist/*','tmp/*']
			test   :  ['test/js/*','test/css/*']


		coffee:
			build:
				expand: true
				flatten: true
				cwd: ''
				src: ['src/*.coffee']
				dest: 'tmp/'
				ext: '.js'
			test:
				options:
					bare: true
				expand: true
				flatten: true
				cwd: ''
				src: ['test/coffee/*.coffee']
				dest: 'test/js/'
				ext: '.js'


		concat:
			build:
				# Please keep in mind, that the order of the source files is important!
				# Sources that depend on other sources must be after the source, they depend on.
				src : ['tmp/b_dropdown-option.js','tmp/b_dropdown-base.js','tmp/b_dropdown-json.js','tmp/b_dropdown-select.js', 'tmp/b_dropdown.js']
				dest: 'dist/b_dropdown.js'
			test:
				src : ['test/js/test.js', 'test/js/testApp.js' ]
				dest: 'test/js/test.js'


		concurrent:
			test:
				tasks: ['nodemon:test', 'watch:test']
				options:
					logConcurrentOutput: true

		copy:
			build:
				files: [
					{
						expand: true
						flatten: true
						src: ['src/b_dropdown.less']
						dest: 'dist/'
					}
				]
			test:
				files: [
					{
						expand: true
						flatten: true
						src: [
							'bower_components/jquery/dist/jquery.js'
							'bower_components/requirejs/require.js'
							'dist/b_dropdown.js'
						]
						dest: 'test/js/contrib/'
					}
				]


		less:
			build:
				options:
					compress    : false,
					yuicompress : false,
					cleancss    : false,
					optimization: null
				files:
					'dist/b_dropdown.css': 'src/b_dropdown.less'

			buildMin:
				options:
					compress    : true,
					yuicompress : true,
					cleancss    : true,
					optimization: 2
				files:
					'dist/b_dropdown.min.css': 'src/b_dropdown.less'

			test:
				options:
					compress    : false,
					yuicompress : false,
					cleancss    : false,
					optimization: null

				files:
					"test/css/test.css": "test/less/test.less"


		nodemon:
			test:
				script: 'test/server/server.coffee'
				options:
					env:
						PORT: config.testServerPort
						DIRECTORY: config.testCodeDirectory
					ignore: ['**']


		requirejs:
			test:
				options:
					name          : 'config'
					mainConfigFile: 'test/js/config.js'
					out           : 'test/js/test.js'
					optimize      : 'none'
					findNestedDependencies: true


		uglify:
			options:
				banner: '<%= banner %>'

			dist:
				src: 'dist/b_dropdown.js'
				dest: 'dist/b_dropdown.min.js'


		watch:
			test:
				files: ['src/**/*.coffee','src/**/*.less']
				tasks: ['testBuild']


	# These plugins provide necessary tasks.
	grunt.loadNpmTasks 'grunt-concurrent'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-requirejs'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-nodemon'


	grunt.registerTask 'build', ['coffee:build', 'concat:build', 'copy:build','less:build','less:buildMin']
	grunt.registerTask 'release', ['clean:release', 'build', 'uglify']

	grunt.registerTask 'testBuild', ['clean:test', 'build', 'copy:test', 'coffee:test', 'requirejs:test', 'concat:test', 'less:test']
	grunt.registerTask 'test', ['testBuild', 'concurrent:test']


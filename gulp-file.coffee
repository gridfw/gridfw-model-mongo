###*
 * Gulp file
###
GridfwGulp= require 'gulp-gridfw'
# GridfwGulp= require 'gulp-gridfw'
Gulp= require 'gulp'

compiler= new GridfwGulp Gulp,
	isProd: <%- isProd %>

params= {
	isProd: <%- isProd %>
}

compiler
	###*********
	 * COMPILE js
	###
	.js
		name:	'JS files'
		src:	'assets/index.coffee'
		dest:	'build/'
		watch:	'assets/**/*.coffee'
		data:	params
	###*********
	 * COMPILE test files
	###
	.js
		name:	'Test files'
		src:	'test-assets/**/*.coffee'
		watch:	'test-assets/**/*.coffee'
		dest:	'test-build/'
		data:	params
	.run()


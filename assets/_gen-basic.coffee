###*
 * Basic query generation
###
class QueryGen
	constructor: ->
		@_options= _create null
		return
	###*
	 * add cutom option
	###
	option: (key, value)->
		@_options[key]= value
		return this

	###*
	 * generate options format
	###
	_buildOptions: ->
		# check options
		arr= []
		acceptedOptions= @_acceptedOptions
		for k in Object.keys @_options
			arr.push k unless k in acceptedOptions
		throw new Error "Illegal options: #{arr.join ','}" if arr.length
		# build options
		JSON.stringify @_options

	### wrappers ###
	timeout: (timeout)-> @option 'maxTimeMS', timeout
	comment: (comment)-> @option 'comment', comment
	hint: (hint)-> @option 'hint', hint

	### build function ###
	_build: ->
		@buildCorp()

	###*
	 * ToString
	###
	toString: -> @_buildMain()

###
# GETTERS
###
_defineProperties QueryGen.prototype,
	explain: get: -> @option 'explain', yes
	raw: get: -> @option 'raw', yes

### normalise query ###
_stringifyQuery= (query)->
	unless typeof query is 'string'
		query= JSON.stringify query
	query
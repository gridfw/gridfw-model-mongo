###*
 * UpdateManyQuery
###
class UpdateManyQuery extends QueryGen
	constructor: (parent, query, update)->
		super parent
		@_query= query
		@_update= update
		return

	# accepted options
	_acceptedOptions: 'upsert,w,wtimeout,j,arrayFilters,session'.split ','

	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout

	###*
	 * Generate fx corp
	###
	_buildMain: -> "updateMany(#{_stringifyQuery @_query}, #{_stringifyQuery @_update}, #{@_buildOptions()})"

_defineProperties UpdateManyQuery.prototype,
	upsert: get: -> @option 'upsert', yes

###*
 * UpdateOneQuery
###
class UpdateOneQuery extends QueryGen
	constructor: (parent, query, update)->
		super parent
		@_query= query
		@_update= update
		return

	# accepted options
	_acceptedOptions: 'upsert,w,wtimeout,j,bypassDocumentValidation,arrayFilters,session'.split ','
	
	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout

	###*
	 * Generate fx corp
	###
	_buildMain: -> "updateOne(#{_stringifyQuery @_query}, #{_stringifyQuery @_update}, #{@_buildOptions()})"
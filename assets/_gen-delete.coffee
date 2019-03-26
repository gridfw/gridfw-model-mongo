###*
 * DeleteOneQuery
###
class DeleteOneQuery extends QueryGen
	constructor: (parent, query)->
		super parent
		@_query= query
		return

	# accepted options
	_acceptedOptions: 'w,wtimeout,j,session'.split ','

	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout
	
	###*
	 * Generate fx corp
	###
	_buildMain: -> "deleteOne(#{_stringifyQuery @_query}, #{@_buildOptions()})"

###*
 * Delete many
###
class DeleteManyQuery extends DeleteOneQuery
	constructor: (parent, query)->
		super(parent, query)
		return

	###*
	 * Generate fx corp
	###
	_buildMain: -> "deleteMany(#{_stringifyQuery @_query}, #{@_buildOptions()})"
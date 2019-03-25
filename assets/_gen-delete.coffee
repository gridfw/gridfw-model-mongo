###*
 * DeleteOneQuery
###
class DeleteOneQuery extends QueryGen
	constructor: (query)->
		super()
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
	constructor: (query)-> super(query)

	###*
	 * Generate fx corp
	###
	_buildMain: -> "deleteMany(#{_stringifyQuery @_query}, #{@_buildOptions()})"
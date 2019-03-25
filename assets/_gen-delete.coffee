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
	_buildMain: -> "deleteOne(#{JSON.stringify @_query}, #{@_buildOptions})"

###*
 * Delete many
###
class DeleteManyQuery extends DeleteOneQuery
	constructor: (query)-> super(query)

	###*
	 * Generate fx corp
	###
	_buildMain: -> "deleteMany(#{JSON.stringify @_query}, #{@_buildOptions})"
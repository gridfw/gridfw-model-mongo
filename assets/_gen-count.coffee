###*
 * Document count
###
class DocumentCountQuery extends QueryGen
	constructor: (query)->
		super()
		@_query= query
		return

	# accepted options
	_acceptedOptions: 'collation,hint,limit,maxTimeMS,skip'.split ','

	# find commons
	limit: (nbr)-> @option 'limit', nbr
	skip: (nbr)-> @option 'skip', nbr

	###*
	 * Generate fx corp
	###
	_buildMain: -> "countDocuments(#{JSON.stringify @_query}, #{@_buildOptions})"
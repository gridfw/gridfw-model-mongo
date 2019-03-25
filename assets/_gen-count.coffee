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
	_buildMain: -> "countDocuments(#{_stringifyQuery @_query}, #{@_buildOptions()})"

class ExistsQuery extends DocumentCountQuery
	constructor: (query)->
		super query
		@limit 1
	_buildMain: -> "countDocuments(#{_stringifyQuery @_query}, #{@_buildOptions()}).then(function(doc){return doc.count !== 0})"
###*
 * Document count
###
class DocumentCountQuery extends QueryGen
	constructor: (parent, query)->
		super parent
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
	constructor: (parent, query)->
		super parent, query
		@limit 1
		return
	_buildMain: -> "countDocuments(#{_stringifyQuery @_query}, #{@_buildOptions()}).then(function(nbr){return nbr !== 0})"
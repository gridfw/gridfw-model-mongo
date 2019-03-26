###*
 * DistinctQuery
###
class DistinctQuery extends QueryGen
	constructor: (parent, key, query)->
		super parent
		@_key= key
		@_query= query
		return

	# accepted options
	_acceptedOptions: 'readPreference,maxTimeMS,session'.split ','

	###*
	 * Generate fx corp
	###
	_buildMain: -> "distinct(#{JSON.stringify @_key}, #{_stringifyQuery @_query}, #{@_buildOptions()})"
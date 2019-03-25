###*
 * DistinctQuery
###
class DistinctQuery extends QueryGen
	constructor: (key, query)->
		super()
		@_key= key
		@_query= query
		return

	# accepted options
	_acceptedOptions: 'readPreference,maxTimeMS,session'.split ','

	###*
	 * Generate fx corp
	###
	_buildMain: -> "distinct(#{JSON.stringify @_key}, #{JSON.stringify @_query}, #{@_buildOptions})"
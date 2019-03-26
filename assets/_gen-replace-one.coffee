###*
 * ReplaceOneQuery
###
class ReplaceOneQuery extends QueryGen
	constructor: (parent, query, doc)->
		super parent
		@_query= query
		@_doc= doc
		return

	# accepted options
	_acceptedOptions: 'upsert,w,wtimeout,j,bypassDocumentValidation,session'.split ','
	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout

	###*
	 * Generate fx corp
	###
	_buildMain: -> "replaceOne(#{_stringifyQuery @_query}, #{_stringifyQuery @_doc}, #{@_buildOptions()})"

_defineProperties ReplaceOneQuery.prototype,
	upsert: get: -> @option 'upsert', yes
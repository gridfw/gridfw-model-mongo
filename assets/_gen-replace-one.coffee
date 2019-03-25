###*
 * ReplaceOneQuery
###
class ReplaceOneQuery extends QueryGen
	constructor: (query, doc)->
		super()
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
	_buildMain: -> "replaceOne(#{JSON.stringify @_query}, #{JSON.stringify @_doc}, #{@_buildOptions})"

_defineProperties ReplaceOneQuery.prototype,
	upsert: get: -> @option 'upsert', yes
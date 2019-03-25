###*
 * Aggregate query generation
###
class BulkWriteQuery extends QueryGen
	constructor: (writes)->
		super()
		@_writes= writes
		return

	# accepted options
	_acceptedOptions: 'w,wtimeout,j,serializeFunctions,ordered,bypassDocumentValidation,session'.split ','

	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout

	###*
	 * Generate fx corp
	###
	_buildMain: -> "bulkWrite(#{_stringifyQuery @_writes}, #{@_buildOptions()})"


###
# GETTERS
###
_defineProperties BulkWriteQuery.prototype,
	ordered: get: -> @option 'ordered', yes
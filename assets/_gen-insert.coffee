###*
 * InsertOneQuery
###
class InsertOneQuery extends QueryGen
	constructor: (doc)->
		super()
		@_doc= doc
		return
	# accepted options
	_acceptedOptions: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
	### wrappers ###
	timeout: (timeout)-> @option 'wtimeout', timeout
	###*
	 * Generate fx corp
	###
	_buildMain: -> "insertOne(#{_stringifyQuery @_doc}, #{@_buildOptions()})"


###*
 * InsertManyQuery
###
class InsertManyQuery extends InsertOneQuery
	constructor: (docs)->
		super()
		@_docs= docs
		return
	###*
	 * Generate fx corp
	###
	_buildMain: -> "insertMany(#{_stringifyQuery @_docs}, #{@_buildOptions()})"
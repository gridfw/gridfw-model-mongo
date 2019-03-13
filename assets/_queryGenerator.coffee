
### elements wrapper ###
_queryMethodWrapeprParamRegex= /^\$[0-9]+$/
_argsCheckWp=
	object: (v)-> throw 'Expected object or param' unless typeof v is 'object' and v
	unsigned: (v)-> throw 'Expected positive integer or param' unless Number.isSafeInteger(v) and v>=0
	string: (v)-> throw 'Expected string or param' unless typeof v is 'string'

_queryMethodWrapepr= (fxName, checkArgFx)->
	value: ->
		try
			argv= arguments[0]
			# check args
			throw 'Expected one argument' unless arguments.length is 1
			# check it's param
			unless typeof argv is 'string' # and _queryMethodWrapeprParamRegex.test argv
				checkArgFx argv
				argv= JSON.stringify argv
			# add
			@_options[fxName]= argv
			# chain
			this
		catch err
			if typeof err is 'string'
				throw new Error "#{fxName}>> #{err}"
			else
				throw err
_queryEleWrapper= (fxName)->
	value: (arg)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected string' unless typeof arg is 'string'
		# add
		if (previousFx= @_elWrapper) and previousFx isnt fxName
			throw new Error "Could not use #{previousFx} and #{fxName} at the same time"
		@_elWrapper= fxName
		@['_'+ fxName]= arg
		# chain
		this
_queryGetterWrapper= (diretiveName, value)->
	value= true if arguments.length is 1
	get: ->
		@_options[diretiveName] = value
		# chain
		this
_queryGFlagWrapper= (diretiveName, value)->
	value= yes if arguments.length is 1
	get: ->
		# add
		if (previousFx= @_elWrapper) and previousFx isnt fxName
			throw new Error "Could not use #{previousFx} and #{fxName} at the same time"
		@_elWrapper= fxName
		@_elWrapperV= value
		@['_' + diretiveName] = value
		# chain
		this

### BASIC QUERY GENERATOR ###
class QueryBasic
	constructor: ()->
		_defineProperties this,
			_options: value: _create null
		@_convertDocs= no # do not convert response doc into models
		return

_defineProperties QueryBasic.prototype,
	timeout: _queryMethodWrapepr 'maxTimeMS', _argsCheckWp.unsigned
	options: value: (options)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected object' unless typeof options is 'object' and options
		Object.assign @_options, options # copy options
		# chain
		this
	# build
	build: -> throw new Error 'Build is missing'

###*
 * FIND
 * @example
 * $0 means "this"
 * $n mean arguments[n+1]
 * 
 * findUserByName(userName, {limit:5, skip:2 }): MongoRepo.find('{name: $1}').skip('$2 && $2.skip || 2').limit('$2 && $2.limit || 100')
###
class FindQueryGen extends QueryBasic
	constructor: (query)->
		do super
		@_query= query
		@_convertDocs= yes # do convert docs into models
		return
	###*
	 * Generate function
	###
	build: ->
		# distinct
		if @_elWrapper
			# create
			fx= _QUERY_FX_CREATOR[@_elWrapper]
			# check param _queryMethodWrapeprParamRegex
			if fx in ['updateWith', 'replaceWith']
				throw new Error "#{fx} expects argument to be '$n' format only" unless _queryMethodWrapeprParamRegex.test @_elWrapperV
				@_paramToDB= @_elWrapperV
		else if @_options.limit is 1
			fx= _QUERY_FX_CREATOR.findOne
		else
			fx= _QUERY_FX_CREATOR.find
		return fx this
		

_defineProperties FindQueryGen.prototype,
	skip: _queryMethodWrapepr 'skip', _argsCheckWp.unsigned
	limit: _queryMethodWrapepr 'limit', _argsCheckWp.unsigned
	sort: _queryMethodWrapepr 'sort', _argsCheckWp.object
	fields: _queryMethodWrapepr 'projection', _argsCheckWp.object

	hint: _queryMethodWrapepr 'hint', _argsCheckWp.object
	min: _queryMethodWrapepr 'min', _argsCheckWp.unsigned
	max: _queryMethodWrapepr 'max', _argsCheckWp.unsigned
	comment: _queryMethodWrapepr 'comment', _argsCheckWp.string

	# getters
	'new': _queryGetterWrapper 'returnOriginal', false

	upsert: _queryGetterWrapper 'upsert'
	explain: _queryGetterWrapper 'explain'
	tailable: _queryGetterWrapper 'tailable'
	raw: _queryGetterWrapper 'raw'
	partial: _queryGetterWrapper 'partial'

	# distinct
	distinct: _queryEleWrapper 'distinct'
	updateWith: _queryEleWrapper 'updateWith'
	replaceWith: _queryEleWrapper 'replaceWith'
	remove: _queryGFlagWrapper 'remove' # remove found document
	count: _queryGFlagWrapper 'count' # return document count instead of document list
		
	# do not convert response documents into models
	native: get: ->
		@_convertDocs= no # do not convert docs into models
		# chain
		this

### INSERT ###
class InsertQueryGen extends QueryBasic
	constructor: ->
		do super
		_defineProperties this,
			_inserts: value: []
			_insertAll: value: []
		@_options.forceServerObjectId= yes # force server ids instead of driver
		return
	###*
	 * Generate function
	###
	build: ->
		if @_inserts.length is 1 and @_insertAll.length is 0
			fx= _QUERY_FX_CREATOR.insertOne
			@_paramToDB= @_inserts[0]
		else
			fx= _QUERY_FX_CREATOR.insertMany
			@_paramToDB1= @_inserts
			@_paramToDBL= @_insertAll
		return fx this
_defineProperties InsertQueryGen.prototype,
	timeout: _queryMethodWrapepr 'wtimeout', _argsCheckWp.unsigned
	insert: value: (doc)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected format $n' unless typeof doc is 'string'and _queryMethodWrapeprParamRegex.test doc
		@_inserts.push doc
		# chain
		this
	insertAll: value: (docs)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected format $n' unless typeof docs is 'string'and _queryMethodWrapeprParamRegex.test docs
		@_insertAll.push docs
		# chain
		this

	# flags
	localId: _queryGetterWrapper 'forceServerObjectId', false # use driver id instead of server generated id
	ordered: _queryGetterWrapper 'ordered'

### INSERT ###
class UpdateQueryGen extends QueryBasic
	constructor: (query, update)->
		do super
		_defineProperties this,
			_query: value: query
			_update: value: update
		return
	###*
	 * Generate function
	###
	build: ->
		if @_limit is 1
			fx= _QUERY_FX_CREATOR.updateOne
		else
			fx= _QUERY_FX_CREATOR.updateMany
		return fx this
_defineProperties UpdateQueryGen.prototype,
	timeout: _queryMethodWrapepr 'wtimeout', _argsCheckWp.unsigned
	upsert: _queryGetterWrapper 'upsert'
	limit: value: (n)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Limit for delete expected 0 (means all) or 1' unless n in [0, 1]
		@_limit= n
		# chain
		this

### DELETE ###
class DeleteQueryGen extends QueryBasic
	constructor: (query)->
		do super
		@_options.query= query
		return
	###*
	 * Generate function
	###
	build: ->
		if @_limit is 1
			fx= _QUERY_FX_CREATOR.deleteOne
		else
			fx= _QUERY_FX_CREATOR.deleteMany
		return fx this
# getters
_defineProperties DeleteQueryGen.prototype,
	timeout: _queryMethodWrapepr 'wtimeout', _argsCheckWp.unsigned
	limit: value: (n)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Limit for delete expected 0 (means all) or 1' unless n in [0, 1]
		@_limit= n
		# chain
		this
	

### REPLACE ###
class ReplaceQueryGen extends QueryBasic
	constructor: (query, doc)->
		do super
		throw new Error 'Expect format $n as second arguments' unless typeof doc is 'string' and _queryMethodWrapeprParamRegex.test doc
		@_query= query
		@_doc= doc
		return
	###*
	 * Generate function
	###
	build: ->
		# check param _queryMethodWrapeprParamRegex
		@_paramToDB= @_doc
		# fx
		_QUERY_FX_CREATOR.replaceOne this
# getters
_defineProperties ReplaceQueryGen.prototype,
	timeout: _queryMethodWrapepr 'wtimeout', _argsCheckWp.unsigned
	upsert: _queryGetterWrapper 'upsert'
	

### AGGREGRATION ###	
class AggregationQueryGen extends QueryBasic
	constructor: ()->
		do super
		_defineProperties this,
			_pipe: value: []
			_pipeAll: value: []
		return
	###*
	 * Generate function
	###
	build: -> _QUERY_FX_CREATOR.aggregate this
# getters
_defineProperties AggregationQueryGen.prototype,
	timeout: _queryMethodWrapepr 'maxTimeMS', _argsCheckWp.unsigned
	pipe: value: (arg)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected String' unless typeof arg is 'string'
		@_pipe.push arg
		# chain
		this
	pipeAll: value: (docs)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected String' unless typeof arg is 'string'
		@_pipeAll.push arg
		# chain
		this

	hint: _queryMethodWrapepr 'hint', _argsCheckWp.object

	# flags
	explain: _queryGetterWrapper 'explain'
	raw: _queryGetterWrapper 'raw'

### BULK WRITE ###
class BulkWriteQueryGen extends QueryBasic
	constructor: ()->
		do super
		_defineProperty this, '_write', value: []
		return
	###*
	 * Generate function
	###
	build: -> _QUERY_FX_CREATOR.bulkWrite this
# getters
_defineProperties BulkWriteQueryGen.prototype,
	timeout: _queryMethodWrapepr 'wtimeout', _argsCheckWp.unsigned
	write: value: (arg)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected String' unless typeof arg is 'string'
		@_write.push arg
		# chain
		this
	writeAll: value: (docs)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected list of Strings' unless Array.isArray(docs) and docs.every (doc)-> typeof doc is 'string'
		writeLst= @_write
		writeLst.push doc for doc in docs
		# chain
		this
	# flags
	ordered: _queryGetterWrapper 'ordered'


###*
 * Basic query generation
###
class QueryGen
	constructor: (@_parent)->
		@_options= _create null
		return
	###*
	 * add cutom option
	###
	option: (key, value)->
		@_options[key]= value
		return this

	###*
	 * generate options format
	###
	_buildOptions: ->
		# check options
		arr= []
		acceptedOptions= @_acceptedOptions
		for k in Object.keys @_options
			arr.push k unless k in acceptedOptions
		throw new Error "Illegal options: #{arr.join ','}" if arr.length
		# build options
		JSON.stringify @_options

	### wrappers ###
	timeout: (timeout)-> @option 'maxTimeMS', timeout
	comment: (comment)-> @option 'comment', comment
	hint: (hint)-> @option 'hint', INDEX_PREFIX + hint

	### build function ###
	_buildM: -> @_buildMain().replace /"@{.+?}"/g, (s)-> JSON.parse(s).slice 2, -1
	_build: ->
		# check params
		params= @_parent._params
		# get count of args without default value
		argsWithoutDefaultNbr= 0
		for k in params
			break if k.indexOf('=') > -1
			++argsWithoutDefaultNbr
		# create function corp
		# check arguments
		fx=[]
		if argsWithoutDefaultNbr is params.length
			fx.push "if(arguments.length !== #{argsWithoutDefaultNbr}) throw new Error('Expected #{argsWithoutDefaultNbr} arguments')"
		else
			if argsWithoutDefaultNbr
				fx.push "if(arguments.length < #{argsWithoutDefaultNbr}) throw new Error('Expected at least #{argsWithoutDefaultNbr} arguments')"
			fx.push "if(arguments.length > #{params.length}) throw new Error('Arguments count exceeds #{params.length}')"
		# add fx corp
		fx.push "return this.c.#{@_buildM()}"
		# compile and return
		fxArgs= [Function]
		fxArgs.push k for k in params
		fxArgs.push fx.join ";\n"
		fx= new (Function.prototype.bind.apply Function, fxArgs)
		man= JSON.stringify "#{@_parent._man || ''}\n\nSIGNATURE:\n#{@toString()}"
		_defineProperties fx,
			toString: value: new Function "return #{man}"
		return fx

	###*
	 * ToString
	###
	toString: -> "(#{@_parent._params.join ', '})-> #{@_buildM()}"

###
# GETTERS
###
_defineProperties QueryGen.prototype,
	explain: get: -> @option 'explain', yes
	raw: get: -> @option 'raw', yes
	# MARKERS
	# Do not convert docs to Models
	native: get: ->
		@_native= on
		return this # chain

### normalise query ###
_stringifyQuery= (query)-> JSON.stringify query
	# unless typeof query is 'string'
	# 	query= JSON.stringify query
	# query
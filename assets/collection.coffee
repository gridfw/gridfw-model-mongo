###*
 * Collection
###
COLLECTION_NAME_REGEX= /^[A-Z][a-z_]*$/
class Collection
	constructor: (db, name, indexes)->
		throw 'Collection name expected string' unless typeof name is 'string'
		throw "Collection name must be: #{COLLECTION_NAME_REGEX.toString()}" unless COLLECTION_NAME_REGEX.test name
		_defineProperties this,
			db: value: db
			name: value: name
			indexes: value: indexes or []
		return
	###*
	 * Set indexes
	###
	# setIndexes: (indexes)->
	###*
	 * Define methods
	###
	define: (methods)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof methods is 'object' and methods
			for k,v of methods
				throw "#{k} expected function" unless typeof v is 'function'
				throw "#{k} already set" if k of this
				_defineProperty this, k, value: v
			return this # chain
		catch err
			err= new Error "#{@name} - Define methods>> #{err}" if typeof err is 'string'
			throw err
		
	### COLLECTION MANIPULATION ###
	save: (doc)->
		
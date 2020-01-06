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
	_reloadIndexes: ->
		try
			indexes= @indexes
			collection= @c
			indexPrefix= @db.prefix
			# Check
			indexNames= []
			throw 'Expected list of indexes' unless Array.isArray indexes
			for index,i in indexes
				throw new Error "Posistion #{i}: Expected object" unless typeof index is 'object' and index
				idxName= index.name
				throw "Posistion #{i}: Index name expected string" unless typeof idxName is 'string'
				throw "Posistion #{i}: Index name must starts with: #{indexPrefix}" unless idxName.startsWith indexPrefix
				throw "Posistion #{i}: Dupplicated index name: #{idxName}" if idxName in indexNames
				indexNames.push idxName
			# get existing indexes
			existingIndexes= await @indexes()
			nonModifiedIndexes= []
			if existingIndexes and existingIndexes.length
				for index in existingIndexes
					idxName= index.name
					continue unless idxName.startsWith indexPrefix
					if idxName in indexNames
						nonModifiedIndexes.push idxName
					else
						console.log "MONGO DROP INDEX>> #{idxName}"
						await collection.dropIndex idxName
			# filter new indexes
			newIndexes= indexes.filter (index)-> index.name not in nonModifiedIndexes
			if newIndexes.length
				for index in newIndexes
					console.log "MONGO CREATE INDEXES>> #{index.name}"
				await collection.createIndexes newIndexes
			return
		catch err
			err= new Error "#{@name} - Reload indexes>> #{err}" if typeof err is 'string'
			throw err
	# When disconnect from Mongo
	_whenDisconnect: ->
		delete @c
		delete @collection
		return

		
	### COLLECTION MANIPULATION ###
	save: (doc)->
		if doc._id
			@c.replaceOne {_id: doc._id}, doc, upsert: yes
		else
			@c.insertOne doc
	insertOne: (doc)-> @c.insertOne doc
	insertMany: (docs)-> @c.insertMany docs

	drop: -> @c.drop()
	indexes: -> @c.indexes()

# GETTER
_getCollectionOnce= ->
	db= @db.db
	throw new Error 'Not connected!' unless db
	collection = db.collection @name
	property=
		value: collection
		configurable: yes
	_defineProperties this,
		c: property
		collection: property
	collection
_defineProperties Collection.prototype,
	c: get: _getCollectionOnce
	collection: get: _getCollectionOnce

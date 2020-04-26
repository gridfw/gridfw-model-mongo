###*
 * Collection
###
COLLECTION_NAME_REGEX= /^[a-z][a-z_]*$/i
class Collection
	constructor: (db, name, indexes, model)->
		throw 'Collection name expected string' unless typeof name is 'string'
		throw "Collection name must be: #{COLLECTION_NAME_REGEX.toString()}" unless COLLECTION_NAME_REGEX.test name
		@db= db
		@name= name
		@_indexes= indexes or []
		@model= model
		@_defineCbs= [] # define callbacks
		return
	###*
	 * Set indexes
	###
	# setIndexes: (indexes)->
	###*
	 * Define methods
	###
	define: (cb)->
		throw new Error 'Illegal arguments' unless arguments.length is 1 and typeof cb is 'function'
		@_defineCbs.push cb
		do @_applyDefine if @collection # define callbacks if already connected
		this # chain
	_applyDefine: ->
		collection= @collection
		model= @model
		for cb in @_defineCbs
			result= cb collection, model
			throw new Error "::define result expected object" unless typeof result is 'object' and result
			_assign this, result
		return
	_reloadIndexes: ->
		try
			indexes= @_indexes
			collection= @collection
			indexPrefix= @db._prefix
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
		@collection= null
		# remove all created methods
		for k of this
			if @hasOwnProperty(k) and typeof @[k] is 'function'
				@[k]= null
		return
	_onConnect: ->
		# Get collection
		@collection = @db.db.collection @name
		# Define properties
		@_applyDefine()
		# reload index
		await @_reloadIndexes()
		return
		
	### COLLECTION MANIPULATION ###
	save: (doc)->
		if doc._id
			@collection.replaceOne {_id: doc._id}, doc, upsert: yes
		else
			@collection.insertOne doc
	insertOne: (doc)-> @collection.insertOne doc
	insertMany: (docs)-> @collection.insertMany docs

	drop: -> @collection.drop()
	indexes: -> @collection.indexes()

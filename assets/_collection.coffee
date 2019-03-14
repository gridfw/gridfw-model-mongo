###*
 * Mongo Collection
###
class CollectionRepository
	###*
	 * Collection mapper
	 * @private @param {MongoRepository} mongoRepo - parent mongo repository
	 * @param  {String} name  - Collection name
	 * @param  {Model} model  - Model representing collection architecture
	 * @param  {List} indexes - list of used indexes
	###
	constructor: (mongoRepo, name, model, indexes)->
		throw new Error 'Indexes expected array' if indexes and not Array.isArray indexes
		
		_defineProperties this,
			name: value: name
			Model: value: model
			# private
			_i: value: indexes or []
			_MR: value: mongoRepo
			# Model.fromDB
			_m: value: model.fetch.bind model
		return
	###*
	 * define methods
	###
	define: (methods)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof methods is 'object' and methods
			for k,v of methods
				throw "#{k} already set" if k of this
				unless typeof v is 'function'
					if typeof v.build is 'function'
						v= v.build()
					else
						throw "Illegal expression for #{k}"
				_defineProperty this, k, value: v
			# chain
			return this
		catch err
			if typeof err is 'string'
				throw new Error "#{@name}-Define methods>> #{err}"
			else throw err
	###*
	 * Get document by id
	###
	get: (docId, fields)->
		doc= await @c.findOne {_id: docId}, {projection: fields}
		if doc
			await @_m doc # Model.fetch
		doc
	###*
	 * Save document
	 * @param {Document } doc - document to save
	###
	save: (doc)->
		try
			# save to database and return promise
			if doc._id
				@c.replaceOne {_id: doc._id}, doc, upsert: yes
			else
				@c.insertOne doc
		catch err
			throw new Error "Expected #{@Model.name} model document" unless doc instanceof @Model
			throw err
	saveAll: (docs)->
		try
			# filter docs with and without ids
			docsWithIds= []
			docsWithoutIds= []
			for doc in docs
				if doc._id
					docsWithIds.push doc
				else
					docsWithoutIds.push doc
			# collection
			collection= @c
			# replace docs with ids
			if docsWithIds.length
				jobs= docsWithIds.map (doc)-> collection.replaceOne {_id: doc._id}, doc, upsert: yes
			else
				jobs= []
			# insert docs without ids
			if docsWithoutIds.length
				jobs.push collection.insertMany docsWithoutIds
			# return promise
			return Promise.all jobs
		catch err
			throw new Error 'Expected document array' unless Array.isArray docs
			for doc, i in docs
				throw new Error "Doc at index #{i} isn't of type #{@Model.name}" unless doc instanceof @Model
			throw err
	###*
	 * Drop collection
	 * @return promise
	###
	drop: -> @c.drop()

	###*
	 * Get all indexes
	###
	indexes: -> @c.indexes()

	###*
	 * Reload indexes
	###
	reloadIndexes: ->
		# get collection
		collection= @c
		
		throw new Error 'Not connected' unless collection
		# check indexes has correct names
		indexNames= []
		indexes= []
		for idx in @_i
			throw new Error 'All indexes expected objects' unless typeof idx is 'object' and idx
			throw new Error "All indexes expect a string name" unless typeof idx.name is 'string'
			ob= _create null
			_assign ob, idx
			ob.name= INDEX_PREFIX + ob.name
			throw new Error "Index duplicated: #{idx.name}" if ob.name in indexNames
			indexNames.push ob.name
			indexes.push ob
		# get existing indexes
		colIndexes= await @c.indexes()
		colIndexNames= []
		jobs=[]
		if colIndexes and colIndexes.length
			for idx in colIndexes
				idxName= idx.name
				if idxName.startsWith INDEX_PREFIX
					if idxName in indexNames
						colIndexNames.push idxName
					else
						# drop if not anymore
						jobs.push collection.dropIndex idxName
		# insert new indexes
		newIndexes= indexes.filter (idx)-> idx.name not in colIndexNames
		if newIndexes.length
			jobs.push collection.createIndexes newIndexes
		# return
		Promise.all jobs
	###*
	 * Rename collection
	 * @return promise
	###
	rename: (newName, dropTarget)->
		# check if already exists
		if @_MR.all.hasOwnProperty newName
			throw new Error "An other collection set with name: #{newName}" unless dropTarget
			delete @_MR.all[newName]
		# drop from mongo
		if @c
			await @c.rename newName, dropTarget: !!dropTarget
		return

	###*
	 * CallBack when disconnect
	 * @private
	###
	_whenDisconnect: ->
		# remove native collection
		_defineProperty this, 'Collection',
			value: null
			configurable: on
		return

# Collection getter
_getCollection= ->
	db= @_MR.db
	throw new Error 'Not connected!' unless db
	collection = db.collection @name
	_defineProperty this, 'Collection',
		value: collection
		configurable: on
	collection
# Getters
_defineProperties CollectionRepository.prototype,
	# native mongo collection
	c: get: _getCollection
	Collection: get: _getCollection



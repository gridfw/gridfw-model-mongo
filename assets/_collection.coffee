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
		_defineProperties
			name: value: name
			Model: value: model
			# private
			_i: value: indexes
			_MR: value: mongoRepo
			# Model.fromDB
			_m:
				value: @Model.fromDB.bind @Model
		return
	###*
	 * Get document by id
	###
	get: (docId)->
		doc= await @c.findOne id: docId
		if doc
			@_m doc # Model.fromDB
		doc
	###*
	 * Save document
	 * @param {Document } doc - document to save
	###
	save: (doc)->
		try
			# get storable version on the database
			doc = doc.toDB()
			# save to database and return promise
			if doc._id
				@c.replaceOne {_id: doc._id}, doc, upsert: yes
			else
				@c.insertOne doc, forceServerObjectId: yes
		catch err
			throw new Error "Expected #{@Model.name} model document" unless doc instanceof @Model
			throw err
	saveAll: (docs)->
		try
			# get storable version on the database
			docs = docs.map (doc)-> doc.toDB()
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
				jobs.push collection.insertMany docsWithoutIds, forceServerObjectId: yes
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
	 * Drop all indexes
	 * @return promise
	###
	dropIndexes: -> @c.dropIndexes()

	###*
	 * Get all indexes
	###
	indexes: -> @c.indexes()

	###*
	 * Rename collection
	 * @return promise
	###
	rename: (newName, dropTarget)->
		# check if already exists
		if @_MR.all[newName]
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
	_whenDisconnect:->
		# remove native collection
		_defineProperty this, 'Collection',
			value: null
			configurable: on
		return


# define methods
_colelctionMethods= (methods)->
	throw new Error "#{@name}-Define methods>> Illegal arguments" unless arguments.length is 1 and typeof methods is 'object' and methods

	# chain
	return this


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
	# define methods
	define: value: _colelctionMethods



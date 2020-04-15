'use strict'
{MongoClient, ObjectID: ObjectId}= require 'mongodb'
ModelClass= require 'gridfw-model'
###*
 * UTILS
###
_defineProperty= Object.defineProperty
_defineProperties= Object.defineProperties
_create= Object.create

###*
 * Load data from MongoDB
###
class DB
	###*
	 * @param {String} url - MongoDB server URL & DB
	 * @param  {String} options.prefix	- Index name prefix, used to remove unused indexes
	###
	constructor: (options)->
		try
			# Check arguments
			throw 'Illegal arguments' unless arguments.length is 1
			throw 'Options expected' unless options
			throw 'Expected options.url as string' unless typeof options.url is 'string'
			throw 'options.prefix expected as string' unless typeof options.prefix is 'string'
			# 
			@mongo= MongoClient # Direct access to mongoClient
			@all= {} # store all collections
			@_prefix= options.prefix
			@_url= options.url
			@_db= null
			return
		catch err
			err= new Error "MongoRepositories>> #{err}" if typeof err is 'string'
			throw err
	###*
	 * Connect to Mongo
	 * @see http://mongodb.github.io/node-mongodb-native/3.1/api/MongoClient.html
	 * @param  {String} url - URL to mongo, example: mongodb://localhost:27017/dbName
	 * @optional @param {Object} options - options
	###
	connect: (url, options)->
		throw new Error 'Already connected' if @_db
		# Connect to Mongo
		@_db= _db= await MongoClient.connect url, useNewUrlParser: yes
		@db= _db.db _db.s.options.dbName
		# Create new collections
		do @_createNewCollections
		# prepare collection
		for k, c of @all
			await c._onConnect()
		this # chain
	###*
	 * Close database connection
	###
	close: (force)->
		@_db.close(force)
			.then =>
				# clear DB instance
				@_db= @db= null
				# Emit disconnect
				do @_emitDisconnect
				# return
				return
	_emitDisconnect: ->
		# disconnect all collections
		for k,v of @all
			do v._whenDisconnect
		return
	###*
	 * Do is connected
	###
	isConnected: (options)-> @_db?.isConnected(options)

	###*
	 * Create collection repository
	 * @optional @param {string} options.name - collection name
	 * @param {List} options.indexes - list of used indexes
	 * @param {PlainObject} options.define - define methods
	 * @optional @param {Model} options.model - Model
	###
	from: (options)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			# Assert indexes
			@_assertIndexes options.indexes if options.indexes
			# create collection
			name= options.name
			collection= new Collection this, name, options.indexes, @options.model
			throw "Collection already set: #{name}" if @all[name]?
			@all[name]= collection
			# define methods
			collection.define options.define if options.define
			# return collection
			return collection
		catch err
			err= new Error "DB #{name or ''}>>#{err}" if typeof err is 'string'
			throw err
	# parse ObjectId
	parseObjectId: (value)-> ObjectId.createFromHexString value


	# Create new collections
	_createNewCollections: ->
		db= @db
		dbCollections= (await db.collections()).map (c)-> c.collectionName
		collections= []
		for k, c of @all
			# Create collection
			await db.createCollection(k) unless k in dbCollections
		return
	# Reload all indexes
	# _reloadIndexes: ->
	# 	for k, c of @all
	# 		await c._reloadIndexes()
	# 	return
	# Check indexes
	_assertIndexes: (indexes)->
		throw 'Expected options.indexes to be list' unless Array.isArray indexes
		indexPrefix= @prefix
		for index, i in indexes
			idxName= index.name
			throw "Expected index name as string at position #{i}" unless typeof idxName is 'string'
			throw "Index name expected to start with: #{indexPrefix}" unless idxName.startsWith indexPrefix
		return
module.exports= DB
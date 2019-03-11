'use strict'

Model = require <%= isProd? '../../gridfw-model': 'gridfw-model'
{MongoClient, ObjectID: ObjectId}= require 'mongodb'
# utils
_defineProperty= Object.defineProperty
_defineProperties= Object.defineProperties
_create= Object.create

<%
#=include utils.js
%>

###*
 * MongoDB plugin for Gridfw-model
###

#=include _queryGenerator-create-fxes.coffee
#=include _queryGenerator.coffee
#=include _collection.coffee

class MongoRepository
	constructor: ->
		# collections
		_defineProperties this,
			# map all collections
			all: value: _create null
			MongoClient: value: MongoClient
		return
	# connect to MongoDB
	###*
	 * Connect to MongoDB
	 * @see http://mongodb.github.io/node-mongodb-native/3.1/api/MongoClient.html
	 * @param  {String} url - URL to mongo, example: mongodb://localhost:27017/dbName
	 * @optional @param {Object} options - options
	 * @return {[type]}     [description]
	###
	connect: (url, options)->
		throw new Error 'Already connected' unless @isConnected()
		db= await MongoClient.connect url
		_defineProperties this,
			_db:
				value: db
				configurable: on
			db:
				value: db.db db.s.options.dbName
				configurable: on
		# reload all indexes
		jobs= []
		for k,v of @all
			jobs.push v.reloadIndexes()
		await Promise.all jobs
		return db
	###*
	 * Close database connection
	###
	close: (force)->
		@_db.close(force)
			.then =>
				# clear DB instance
				_defineProperties
					_db:
						value: null
						configurable: on
					db:
						value: null
						configurable: on
				# disconnect all collections
				for v of @all
					do v._whenDisconnect
				# return
				return

	###*
	 * 
	###
	isConnected: (options)-> MongoClient.isConnected(options)


	###*
	 * Create collection repository
	 * @optional @param {string} options.name - collection name
	 * @param {Model} options.model - Model
	 * @param {List} options.indexes - list of used indexes
	 * @param {PlainObject} methods - methods
	###
	from: (options)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			model= options.model
			throw 'Illegal options.model' unless model? and model[Model.SCHEMA]
			name= options.name or model.name
			throw 'Options.name expected string' unless typeof name is 'string'

			# check not already set
			throw "Collection already set: #{name}" if name of @all

			# create repo
			repo= @all[name]= new CollectionRepository this, name, model, indexes

			# add methods
			repo.define options.define if options.define?

			# return
			repo
		catch err
			if typeof err is 'string'
				err= new Error "MongoRepo:: #{err}" 
			throw err
	
	# Interfaces
	find: (query)-> new FindQueryGen query
	insert: (doc)-> (new InsertQueryGen()).insert doc
	insertAll: (docs)-> (new InsertQueryGen()).insertAll docs
	update: (query, update)-> new UpdateQueryGen query, update
	delete: (query)-> new DeleteQueryGen query
	replaceOne: (query, doc)-> new ReplaceQueryGen query, doc

_defineProperties MongoRepository.prototype,
	aggregate: get: -> new AggregationQueryGen()
	bulkWrite: get: -> new BulkWriteQueryGen()

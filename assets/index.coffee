'use strict'

ModelClz = require '<%= isProd ? "gridfw-model" : "../../gridfw-model" %>'
{MongoClient, ObjectID: ObjectId}= require 'mongodb'
# utils
_defineProperty= Object.defineProperty
_defineProperties= Object.defineProperties
_create= Object.create
_assign= Object.assign

###*
 * Prefexing auto created indexes
###
INDEX_PREFIX= 'gfw-'

# ###*
#  * Model plugin
# ###
#=require _gen-basic.coffee
#=require _gen-*.coffee

###*
 * MongoDB plugin for Gridfw-model
###

#c=include _queryGenerator-create-fxes.coffee
#c=include _queryGenerator.coffee
#c=include _collection.coffee
#c=include _cursor-iterator.coffee

_allProxyToString= -> "Repositories[#{Reflect.ownKeys(this).join ', '}]"
ALL_PROXY_DESCRIPTOR=
	get: (obj, attr) ->
		if typeof attr is 'string'
			attrL= attr.toLowerCase()
			if obj.all.hasOwnProperty attrL
				throw new Error "Please use lower-case names to access repositories: [#{attrL}] instead of [#{attr}]"
			else
				throw new Error "Unknown repository: #{attr}"
		return
	set: (obj, attr, value) -> throw new Error "Please don't set values manually to this object!"


<%
	#=include _gen-query.js
%>

# MONGO REPOSITORY
module.exports= class MongoRepository
	constructor: ->
		# all repositories queu
		allRepo= _create (new Proxy this, ALL_PROXY_DESCRIPTOR),
			inspect: value: _allProxyToString
			toString: value: _allProxyToString
			hasOwnProperty: value: Object.hasOwnProperty
		# collections
		_defineProperties this,
			# map all collections
			all: value: allRepo
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
		throw new Error 'Already connected' if @_db
		db= await MongoClient.connect url,
			useNewUrlParser: yes
		_defineProperties this,
			_db:
				value: db
				configurable: on
			db:
				value: db.db db.s.options.dbName
				configurable: on
		# list of all collections
		collections= []
		for k in Object.keys @all
			collections.push @all[k]
		# create all collections of not already
		await collections.map (c)=> @db.createCollection(c.name)
		# reload indexes
		await collections.map (c)=> c.reloadIndexes()
		return db
	###*
	 * Close database connection
	###
	close: (force)->
		@_db.close(force)
			.then =>
				# clear DB instance
				_defineProperties this,
					_db:
						value: null
						configurable: on
					db:
						value: null
						configurable: on
				# disconnect all collections
				for k,v of @all
					do v._whenDisconnect
				# return
				return

	###*
	 * 
	###
	isConnected: (options)-> @_db.isConnected(options)


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
			throw 'Illegal options.model' unless model? and model[ModelClz.SCHEMA]
			name= options.name or model.name
			throw 'Options.name expected string' unless typeof name is 'string'
			name= name.toLowerCase() # collection name is case insensitive

			# check not already set
			throw "Collection already set: #{name}" if @all.hasOwnProperty name

			# create repo
			repo= new CollectionRepository this, name, model, options.indexes
			_defineProperty @all, name,
				value: repo
				enumerable: yes
				configurable: yes

			# add methods
			repo.define options.define if options.define?

			# return
			repo
		catch err
			if typeof err is 'string'
				err= new Error "MongoRepo:: #{err}" 
			throw err
	# parse ObjectId
	parseObjectId: (value)->ObjectId.createFromHexString value
	# Interfaces
	aggregate: <%= _genQuery('AggregateQuery', {pipeline:'array'}) %>
	bulkwrite: <%= _genQuery('BulkWriteQuery', {arr: 'array'}) %>
	### get document count ###
	count: <%= _genQuery('DocumentCountQuery', {query: 'plainObject'}) %>
	exists: <%= _genQuery('ExistsQuery', {query: 'plainObject'}) %>

	deleteMany: <%= _genQuery('DeleteManyQuery', {query: 'plainObject'}) %>
	deleteOne: <%= _genQuery('DeleteOneQuery', {query: 'plainObject'}) %>
	
	distinct: <%= _genQuery('DistinctQuery', {key:'string', query: 'plainObject'}) %>
	findMany: <%= _genQuery('FindManyQuery', {query: 'plainObject'}) %>
	findOne: <%= _genQuery('FindOneQuery', {query: 'plainObject'}) %>
	findOneAndDelete: <%= _genQuery('FindOneAndDeleteQuery', {query: 'plainObject'}) %>
	findOneAndReplace: <%= _genQuery('FindOneAndReplaceQuery', {query: 'plainObject', replacement: 'plainObject'}) %>
	findOneAndUpdate: <%= _genQuery('FindOneAndUpdateQuery', {query: 'plainObject', update:'plainObject'}) %>

	insertOne: <%= _genQuery('InsertOneQuery', {doc: 'plainObject'}) %>
	insertMany: <%= _genQuery('InsertManyQuery', {query: 'array'}) %>

	replaceOne: <%= _genQuery('ReplaceOneQuery', {query: 'plainObject', doc:'plainObject'}) %>

	updateMany: <%= _genQuery('UpdateManyQuery', {query: 'plainObject', update:'plainObject'}) %>
	updateOne: <%= _genQuery('UpdateOneQuery', {query: 'plainObject', update:'plainObject'}) %>

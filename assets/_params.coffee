###*
 * params
###
#=require _gen-basic.coffee
#=require _gen-*.coffee
<%
	#=include _gen-query.js
%>
class ParamsClass
	constructor: (@_params)->
	# manual
	man: (man)->
		throw new Error 'Expected one argument' unless arguments.length is 1
		throw new Error 'Expected string as argument' unless typeof man is 'string'
		@_man= man
		return this # chain
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
	insertMany: <%= _genQuery('InsertManyQuery', {docs: 'array'}) %>

	replaceOne: <%= _genQuery('ReplaceOneQuery', {query: 'plainObject', doc:'plainObject'}) %>

	updateMany: <%= _genQuery('UpdateManyQuery', {query: 'plainObject', update:'plainObject'}) %>
	updateOne: <%= _genQuery('UpdateOneQuery', {query: 'plainObject', update:'plainObject'}) %>

###*
 * Define params
 * @example
 * MongoRepo.params 'param1', 'param2', ...
 * # exec param
 * MongoRepo.params.param1	# simple param
 * MongoRepo.params['param1.subAttr'] # sub attribute
 * MongoRepo.params['param1 + 562'] # expression
###
_defineParamsRegex= /^[a-z0-9]+$/i
_defineParamsRegex2= /^[a-z0-9]+=/i
_defineParams= ()->
	try
		params= Array.from arguments
		# check arguments with default values
		hasDefaultParams= no
		for k in params
			throw 'Arguments expected string' unless typeof k is 'string'
			if k.indexOf('=') isnt -1
				throw "Expected #{_defineParamsRegex2}. Got [#{k}]" unless _defineParamsRegex2.test k
				hasDefaultParams= yes
			else
				throw "Expected #{_defineParamsRegex}. Got [#{k}]" unless _defineParamsRegex.test k
				throw "All params with default values must be in the end" if hasDefaultParams
		new ParamsClass params
	catch err
		err= new Error "PARAMS>> #{err}" if typeof err is 'string'

# param
Object.setPrototypeOf _defineParams, new Proxy({}, {
	get: (obj, key)-> "@{#{key}}"
	set: -> throw new Error 'Could not set this value'
	});
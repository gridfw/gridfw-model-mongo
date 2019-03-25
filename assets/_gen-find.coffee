###*
 * FindManyQuery
###
class FindManyQuery extends QueryGen
	constructor: (query)->
		super()
		@_query= query
		return

	# accepted options
	_acceptedOptions: 'limit,sort,projection,skip,hint,explain,timeout,tailable,batchSize,returnKey,min,max,showDiskLoc,comment,raw,promoteLongs,promoteValues,promoteBuffers,readPreference,partial,maxTimeMS,collation,session'.split ','
	
	### WRAPPERS ###
	limit: (nbr)-> @option 'limit', nbr
	skip: (nbr)-> @option 'skip', nbr
	sort: (sort)-> @option 'sort', sort
	projection: (projection)-> @option 'projection', projection
	
	###*
	 * Generate fx corp
	###
	_buildMain: -> "find(#{JSON.stringify @_query}, #{@_buildOptions})"

###
# GETTERS
###
_defineProperties FindManyQuery.prototype,
	tailable: get: -> @option 'tailable', yes
	partial: get: -> @option 'partial', yes

###*
 * FindOneQuery
###
class FindOneQuery extends FindManyQuery
	constructor: (query)->
		super()
		@_query= query
		return

	###*
	 * Generate fx corp
	###
	_buildMain: -> "findOne(#{JSON.stringify @_query}, #{@_buildOptions})"

###*
 * findOneAndDeleteQuery
###
class FindOneAndDeleteQuery extends QueryGen
	constructor: (query)->
		super()
		@_query= query
		return
	### WRAPPERS ###
	sort: (sort)-> @option 'sort', sort
	projection: (projection)-> @option 'projection', projection
	# accepted options
	_acceptedOptions: 'projection,sort,maxTimeMS,session'.split ','
	###*
	 * Generate fx corp
	###
	_buildMain: -> "findOneAndDelete(#{JSON.stringify @_query}, #{@_buildOptions})"


###*
 * findOneAndReplace
###
class FindOneAndReplaceQuery extends FindOneAndDeleteQuery
	constructor: (query, replacement)->
		super()
		@_query= query
		@_rep= replacement
		return
	# accepted options
	_acceptedOptions: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
	###*
	 * Generate fx corp
	###
	_buildMain: -> "findOneAndReplace(#{JSON.stringify @_query}, #{JSON.stringify @_rep}, #{@_buildOptions})"
_defineProperties FindOneAndReplaceQuery.prototype,
	upsert: get: -> @option 'upsert', yes
	'new': get: -> @option 'returnOriginal', no



###*
 * findOneAndUpdate
###
class FindOneAndUpdateQuery extends FindOneAndReplaceQuery
	constructor: (query, update)->
		super()
		@_query= query
		@_update= update
		return
	# accepted options
	_acceptedOptions: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
	###*
	 * Generate fx corp
	###
	_buildMain: -> "findOneAndUpdate(#{JSON.stringify @_query}, #{JSON.stringify @_update}, #{@_buildOptions})"


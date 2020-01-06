###*
 * FindManyQuery
###
class FindManyQuery extends QueryGen
	constructor: (parent, query)->
		super parent
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
	_buildMain: ->
		r=["find(#{_stringifyQuery @_query}, #{@_buildOptions()})"]
		if @_toArray
			r.push ".toArray()"
			# native
			unless @_native
				r.push ".then(this._mAll)"
		r.join ''

###
# GETTERS
###
_defineProperties FindManyQuery.prototype,
	tailable: get: -> @option 'tailable', yes
	partial: get: -> @option 'partial', yes
	toArray: get: ->
		@_toArray= on
		return this # chain

###*
 * FindOneQuery
###
class FindOneQuery extends FindManyQuery
	constructor: (parent, query)->
		super parent, query
		return

	###*
	 * Generate fx corp
	###
	_buildMain: ->
		r=["findOne(#{_stringifyQuery @_query}, #{@_buildOptions()})"]
		# native
		unless @_native
			r.push ".then(this._m)"
		r.join ''

###*
 * findOneAndDeleteQuery
###
class FindOneAndDeleteQuery extends QueryGen
	constructor: (parent, query)->
		super parent
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
	_buildMain: ->
		r=["findOneAndDelete(#{_stringifyQuery @_query}, #{@_buildOptions()})"]
		# native
		unless @_native
			r.push ".then(r=>{ if(r&&r.value) this._m(r.value); return r;})"
		r.join ''


###*
 * findOneAndReplace
###
class FindOneAndReplaceQuery extends FindOneAndDeleteQuery
	constructor: (parent, query, replacement)->
		super parent
		@_query= query
		@_rep= replacement
		return
	# accepted options
	_acceptedOptions: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
	###*
	 * Generate fx corp
	###
	_buildMain: ->
		r=["findOneAndReplace(#{_stringifyQuery @_query}, #{_stringifyQuery @_rep}, #{@_buildOptions()})"]
		# native
		unless @_native
			r.push ".then(r=>{ if(r&&r.value) this._m(r.value); return r;})"
		r.join ''
_defineProperties FindOneAndReplaceQuery.prototype,
	upsert: get: -> @option 'upsert', yes
	'new': get: -> @option 'returnOriginal', no



###*
 * findOneAndUpdate
###
class FindOneAndUpdateQuery extends FindOneAndReplaceQuery
	constructor: (parent, query, update)->
		super parent, query
		@_update= update
		return
	# accepted options
	_acceptedOptions: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
	###*
	 * Generate fx corp
	###
	_buildMain: ->
		r=["findOneAndUpdate(#{_stringifyQuery @_query}, #{_stringifyQuery @_update}, #{@_buildOptions()})"]
		# native
		unless @_native
			r.push ".then(r=>{ if(r&&r.value) this._m(r.value); return r;})"
		r.join ''


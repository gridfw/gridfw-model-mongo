###*
 * Aggregate query generation
###
class AggregateQuery extends QueryGen
	constructor: (parent, pipeline)->
		super parent
		@_pipeline= pipeline
		return

	# accepted options
	_acceptedOptions: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hint,session'.split ','

	###*
	 * Generate fx corp
	###
	_buildMain: ->
		r=["aggregate(#{_stringifyQuery @_pipeline}, #{@_buildOptions()})"]
		if @_toArray
			r.push ".toArray()"
			# native
			unless @_native
				r.push ".then(this._mAll)"
		r.join ''

###
# GETTERS
###
_defineProperties AggregateQuery.prototype,
	toArray: get: ->
		@_toArray= on
		return this # chain
	
		
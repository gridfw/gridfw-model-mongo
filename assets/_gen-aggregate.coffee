###*
 * Aggregate query generation
###
class AggregateQuery extends QueryGen
	constructor: (pipeline)->
		super()
		@_pipeline= pipeline
		return

	# accepted options
	_acceptedOptions: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hint,session'.split ','

	###*
	 * Generate fx corp
	###
	_buildMain: -> "aggregate(#{JSON.stringify @_pipeline}, #{@_buildOptions})"
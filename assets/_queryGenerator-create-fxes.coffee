###*
 * Create functions
###
_QueryGenCreate= (options)->
	(descriptor)->
		fxOptions= descriptor.options
		supportedOptions= options.options
		# check all options are accepted
		for k in Object.keys fxOptions
			unless k in supportedOptions
				throw new Error "#{options.name}>> Illegal option: #{k}\nSupported are: #{supportedOptions.join ', '}"
		# stringify options
		ops= []
		for k,v of fxOptions
			ops.push "#{k}: #{v}"
		# return function
		fx= options.fx descriptor, ops.join ', '

		# Arguments
		regex= /\$([0-9]+)/g
		args= []
		fxArgs=[]
		while rgx= regex.exec fx
			args.push parseInt rgx[1]
		if args.length
			rgx= Math.max.apply Math, args
			if rgx is 0
				# nothing to do
			else if rgx < 10
				i=1
				while i <= rgx
					fxArgs.push '$' + i
				args= ['var $0=this']
			else
				args= args.map (i)-> "$#{i}= arguments[#{i}]"
				args.push '$0= this'
		# doc toDB calls
		if descriptor._paramToDB
			docToDB = descriptor._paramToDB
				.map (param)->
					"""
					if(typeof #{param}.toDB === 'function')
						#{param}= #{param}.toDB();
					else
						throw new Error("Argument isn't instance of Model");
					"""
				.join ''
		else
			docToDB= ''
		# var declarations
		if args
			args= "var #{args.join ','};\n#{docToDB}\n#{fx}"
		else
			args= fx
		# function corps
		fxArgs.push args
		# return function
		new (Function.prototype.bind.apply Function, fxArgs)

# Find one
_createFindOptions= 'limit,sort,projection,skip,hint,explain,timeout,tailable,batchSize,returnKey,min,max,showDiskLoc,comment,raw,promoteLongs,promoteValues,promoteBuffers,readPreference,partial,maxTimeMS,collation,session'.split ','

_QUERY_FX_CREATOR=
	###
	# Aggregate
	###
	aggregate: _QueryGenCreate
		name: 'aggregate'
		options: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hintsession'.split ','
		fx: (d, options)-> "aggregate([#{d._pipe.join ','}], #{options})"
	###
	# Bulk Write
	###
	bulkWrite: _QueryGenCreate
		name: 'bulkWrite'
		options: 'w,wtimeout,j,serializeFunctions,ordered,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "bulkWrite([#{_write.join ','}], #{options})"
	###
	# FIND DOCUMENTS
	###
	# Count
	count: _QueryGenCreate
		name: 'countDocuments'
		options: 'collation,hint,limit,maxTimeMS,skip'.split ','
		fx: (d, options)-> "countDocuments(#{d._query}, #{options})"
	# distinct
	distinct: _QueryGenCreate
		name: 'distinct'
		options: 'readPreference,maxTimeMS,session'.split ','
		fx: (d, options)-> "distinct(#{d._distinct}, #{d._query}, #{options})"
	# find
	find: _QueryGenCreate
		name: 'find'
		options: _createFindOptions
		fx: (d, options)-> "find(#{d._query}, #{options})"
	# find one
	findOne: _QueryGenCreate
		name: 'findOne'
		options: _createFindOptions
		fx: (d, options)-> "findOne(#{d._query}, #{options})"
	# find one and delete
	findOneAndDelete: _QueryGenCreate
		name: 'findOneAndDelete'
		options: 'projection,sort,maxTimeMS,session'.split ','
		fx: (d, options)-> "findOneAndDelete(#{d._query}, #{options})"
	# find one and replace
	findOneAndReplace: _QueryGenCreate
		name: 'findOneAndReplace'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
		fx: (d, options)-> "findOneAndReplace(#{d._query}, #{d._replaceWith}, #{options})"
	# find one and update
	findOneAndUpdate: _QueryGenCreate
		name: 'findOneAndUpdate'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
		fx: (d, options)-> "findOneAndUpdate(#{d._query}, #{d._updateWith}, #{options})"
	###
	# DELETE DOCUMENTS
	###
	deleteMany: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "deleteMany(#{d._query}, #{options})"
	deleteOne: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "deleteOne(#{d._query}, #{options})"
	###
	# INSERT DOCUMENTS
	###
	insertOne: _QueryGenCreate
		name: 'insertOne'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "insertOne(#{d._inserts[0]}, #{options})"
	insertMany: _QueryGenCreate
		name: 'insertMany'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "insertMany([#{d._inserts.join ','}], #{options})"
	###
	# REPLACE DOCUMENTS
	###
	replaceOne: _QueryGenCreate
		name: 'replaceOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "replaceOne(#{d._query}, #{d._doc}, #{options})"
	###
	# UPDATE DOCUMENTS
	###
	updateMany: _QueryGenCreate
		name: 'updateMany'
		options: 'upsert,w,wtimeout,j,arrayFilters,session'.split ','
		fx: (d, options)-> "updateMany(#{d._query}, #{d._update}, #{options})"
	updateOne: _QueryGenCreate
		name: 'updateOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,arrayFilters,session'.split ','
		fx: (d, options)-> "updateOne(#{d._query}, #{d._update}, #{options})"

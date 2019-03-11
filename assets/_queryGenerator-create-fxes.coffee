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
		# var declarations
		if args
			args= "var #{args.join ','};\n#{fx}"
		else
			args= fx
		# function corps
		fxArgs.push args
		# return function
		new (Function.prototype.bind.apply Function, fxArgs)

###
# Aggregate
###
_CreateAggregation= _QueryGenCreate
	name: 'aggregate'
	options: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hintsession'.split ','
	fx: (d, options)-> "aggregate([#{d._pipe.join ','}], #{options})"

###
# Bulk Write
###
_CreateBulkWrite= _QueryGenCreate
	name: 'bulkWrite'
	options: 'w,wtimeout,j,serializeFunctions,ordered,bypassDocumentValidation,session'.split ','
	fx: (d, options)-> "bulkWrite([#{_write.join ','}], #{options})"

###
# FIND DOCUMENTS
###
# Count
_CreateCount= _QueryGenCreate
	name: 'countDocuments'
	options: 'collation,hint,limit,maxTimeMS,skip'.split ','
	fx: (d, options)-> "countDocuments(#{d._query}, #{options})"

# distinct
_CreateDistinct= _QueryGenCreate
	name: 'distinct'
	options: 'readPreference,maxTimeMS,session'.split ','
	fx: (d, options)-> "distinct(#{d._distinct}, #{d._query}, #{options})"

# Find one
_createFindOptions= 'limit,sort,projection,fields,skip,hint,explain,snapshot,timeout,tailable,batchSize,returnKey,maxScan,min,max,showDiskLoc,comment,raw,promoteLongs,promoteValues,promoteBuffers,readPreference,partial,maxTimeMS,collation,session'.split ','

_CreateFindOne= _QueryGenCreate
	name: 'findOne'
	options: _createFindOptions
	fx: (d, options)-> "findOne(#{d._query}, #{options})"

# xxxx
_CreateXX= _QueryGenCreate
	name: ''
	options: ''.split ','
	fx: (d, options)-> ""

# findOneAndDelete
_CreateFindOneAndDelete= _QueryGenCreate
	name: 'findOneAndDelete'
	options: 'projection,sort,maxTimeMS,session'.split ','
	fx: (d, options)-> "findOneAndDelete(#{d._query}, #{options})"

# findOneAndReplace
_CreateFindOneAndReplace= _QueryGenCreate
	name: 'findOneAndReplace'
	options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
	fx: (d, options)-> "findOneAndReplace(#{d._query}, #{d._replaceWith}, #{options})"

# findOneAndUpdate
_CreateFindOneAndUpdate= _QueryGenCreate
	name: 'findOneAndUpdate'
	options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
	fx: (d, options)-> "findOneAndUpdate(#{d._query}, #{d._updateWith}, #{options})"

###
# DELETE DOCUMENTS
###
_CreateDeleteMany= _QueryGenCreate
	options: 'w,wtimeout,j,session'.split ','
	fx: (d, options)-> "deleteMany(#{d._query}, #{options})"
_CreateDeleteOne= _QueryGenCreate
	options: 'w,wtimeout,j,session'.split ','
	fx: (d, options)-> "deleteOne(#{d._query}, #{options})"

###
# INSERT DOCUMENTS
###
_CreateInsertOne= _QueryGenCreate
	name: 'insertOne'
	options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
	fx: (d, options)-> "insertOne(#{d._inserts[0]}, #{options})"
_CreateInsertMany= _QueryGenCreate
	name: 'insertMany'
	options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
	fx: (d, options)-> "insertMany([#{d._inserts.join ','}], #{options})"

###
# REPLACE DOCUMENTS
###
_CreateReplaceOne= _QueryGenCreate
	name: 'replaceOne'
	options: 'upsert,w,wtimeout,j,bypassDocumentValidation,session'.split ','
	fx: (d, options)-> "replaceOne(#{d._query}, #{d._doc}, #{options})"

###
# UPDATE DOCUMENTS
###
_CreateUpdateMany= _QueryGenCreate
	name: 'updateMany'
	options: 'upsert,w,wtimeout,j,arrayFilters,session'.split ','
	fx: (d, options)-> "updateMany(#{d._query}, #{d._update}, #{options})"
_CreateUpdateOne= _QueryGenCreate
	name: 'updateOne'
	options: 'upsert,w,wtimeout,j,bypassDocumentValidation,arrayFilters,session'.split ','
	fx: (d, options)-> "updateOne(#{d._query}, #{d._update}, #{options})"

###*
 * Create functions
###
_QueryGenCreate= (options)->
	(descriptor)->
		fxOptions= descriptor._options
		supportedOptions= options.options
		# check all options are accepted
		for k in Object.keys fxOptions
			unless k in supportedOptions
				throw new Error "#{options.name}>> Illegal option: #{k}\nSupported are: #{supportedOptions.join ', '}"
		# stringify options
		ops= []
		for k,v of fxOptions
			ops.push "#{k}: #{v}"
		ops= if ops.length then ",{#{ops.join ', '}}" else ''
		# return function
		fx= options.fx descriptor, ops

		# Arguments
		regex= /\$([0-9]+)/g
		args= []
		fxArgs=[Function]
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
					++i
				args= ['$0=this']
			else
				args= args.map (i)-> "$#{i}= arguments[#{i}]"
				args.push '$0= this'

		# var declarations
		if args.length
			args= ["var #{args.join ','};\n"]
		# add doc convertion
		if descriptor._convertDocs
			args.push """
			var Mdle= this.Model;
			return this.c.#{fx}.then(resp=>{
					//TODO add convertion
					console.warn('----- convertion not added')
					return resp
				});
			"""
		else
			args.push "return this.c.#{fx};"

		# function corps
		fxArgs.push args.join ''

		# return function
		new (Function.prototype.bind.apply Function, fxArgs)

### load param for aggregate and others ###
_QueryGenLoadParam= (arr)->
	if len= arr.length
		# Group
		rep= []
		lRep=[]
		i=0
		while i<len
			if arr[i+1] # single
				lRep.push arr[i]
			else # multi
				if lRep.length
					rep.push "[#{lRep.join ','}]"
					lRep.length= 0
				rep.push arr[i]
			i+= 2
		if lRep.length
			rep.push "[#{lRep.join ','}]"
		# response
		return "(#{rep.join ').concat('})"
	else
		throw new Error 'Expected params!'
	return rep

# Find one
_createFindOptions= 'limit,sort,projection,skip,hint,explain,timeout,tailable,batchSize,returnKey,min,max,showDiskLoc,comment,raw,promoteLongs,promoteValues,promoteBuffers,readPreference,partial,maxTimeMS,collation,session'.split ','

_QUERY_FX_CREATOR=
	###
	# Aggregate
	###
	aggregate: _QueryGenCreate
		name: 'aggregate'
		options: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hintsession'.split ','
		fx: (d, options)->"aggregate(#{_QueryGenLoadParam d._pipe}#{options})"
	###
	# Bulk Write
	###
	bulkWrite: _QueryGenCreate
		name: 'bulkWrite'
		options: 'w,wtimeout,j,serializeFunctions,ordered,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "bulkWrite(#{_QueryGenLoadParam d._write}#{options})"
	###
	# FIND DOCUMENTS
	###
	# Count
	count: _QueryGenCreate
		name: 'countDocuments'
		options: 'collation,hint,limit,maxTimeMS,skip'.split ','
		fx: (d, options)-> "countDocuments(#{d._query}#{options})"
	# distinct
	distinct: _QueryGenCreate
		name: 'distinct'
		options: 'readPreference,maxTimeMS,session'.split ','
		fx: (d, options)-> "distinct('#{d._distinct}', #{d._query}#{options})"
	# find
	find: _QueryGenCreate
		name: 'find'
		options: _createFindOptions
		fx: (d, options)-> "find(#{d._query}#{options})"
	# find one
	findOne: _QueryGenCreate
		name: 'findOne'
		options: _createFindOptions
		fx: (d, options)-> "findOne(#{d._query}#{options})"
	# find one and delete
	findOneAndDelete: _QueryGenCreate
		name: 'findOneAndDelete'
		options: 'projection,sort,maxTimeMS,session'.split ','
		fx: (d, options)-> "findOneAndDelete(#{d._query}#{options})"
	# find one and replace
	replaceWith: _QueryGenCreate
		name: 'findOneAndReplace'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
		fx: (d, options)-> "findOneAndReplace(#{d._query}, #{d._replaceWith}#{options})"
	# find one and update
	updateWith: _QueryGenCreate
		name: 'findOneAndUpdate'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
		fx: (d, options)-> "findOneAndUpdate(#{d._query}, #{d._updateWith}#{options})"
	###
	# DELETE DOCUMENTS
	###
	deleteMany: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "deleteMany(#{d._query}#{options})"
	deleteOne: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "deleteOne(#{d._query}#{options})"
	###
	# INSERT DOCUMENTS
	###
	insertOne: _QueryGenCreate
		name: 'insertOne'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "insertOne(#{d._inserts[0]}#{options})"
	insertMany: _QueryGenCreate
		name: 'insertMany'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "insertMany(#{_QueryGenLoadParam d._inserts}#{options})"
	###
	# REPLACE DOCUMENTS
	###
	replaceOne: _QueryGenCreate
		name: 'replaceOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "replaceOne(#{d._query}, #{d._doc}#{options})"
	###
	# UPDATE DOCUMENTS
	###
	updateMany: _QueryGenCreate
		name: 'updateMany'
		options: 'upsert,w,wtimeout,j,arrayFilters,session'.split ','
		fx: (d, options)-> "updateMany(#{d._query}, #{d._update}#{options})"
	updateOne: _QueryGenCreate
		name: 'updateOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,arrayFilters,session'.split ','
		fx: (d, options)-> "updateOne(#{d._query}, #{d._update}#{options})"

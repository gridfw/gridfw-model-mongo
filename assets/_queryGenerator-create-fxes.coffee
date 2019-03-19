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
			return this.c.#{fx};
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

# find and modify cb
findAndModifyCb= '.then(async (doc)=>{if(doc and doc.value){doc.value= await this._m(doc.value);} return doc; });'

_QUERY_FX_CREATOR=
	###
	# Aggregate
	TODO
	###
	aggregate: _QueryGenCreate
		name: 'aggregate'
		options: 'readPreference,cursor,explain,allowDiskUse,maxTimeMS,bypassDocumentValidation,raw,promoteLongs,promoteValues,promoteBuffers,collation,comment,hintsession'.split ','
		fx: (d, options)->
			# load data
			op= "return this.c.aggregate(#{_QueryGenLoadParam d._pipe}#{options})"
			# next operation
			isNative= d._native
			if d._elWrapper is 'toArray'
				op= "#{op}.toArray()#{if isNative then '' else '.then(this._mAll)'}"
			else if d._elWrapper is 'iterator'
				unless isNative
					op= "this._it(#{op});"
			else unless isNative
				throw new Error 'Missing ".toArray", ".iterator" or ".native"'
			# return
			op
	###
	# Bulk Write
	###
	bulkWrite: _QueryGenCreate
		name: 'bulkWrite'
		options: 'w,wtimeout,j,serializeFunctions,ordered,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "this.c.bulkWrite(#{_QueryGenLoadParam d._write}#{options})"
	###
	# FIND DOCUMENTS
	###
	# Count
	count: _QueryGenCreate
		name: 'countDocuments'
		options: 'collation,hint,limit,maxTimeMS,skip'.split ','
		fx: (d, options)-> "this.c.countDocuments(#{d._query}#{options})"
	# distinct
	distinct: _QueryGenCreate
		name: 'distinct'
		options: 'readPreference,maxTimeMS,session'.split ','
		fx: (d, options)-> "this.c.distinct('#{d._distinct}', #{d._query}#{options})"
	# find
	find: _QueryGenCreate
		name: 'find'
		options: _createFindOptions
		fx: (d, options)->
			# load data
			op= "return this.c.find(#{d._query}#{options})"
			# next operation
			isNative= d._native
			if d._elWrapper is 'toArray'
				op= "#{op}.toArray()#{if isNative then '' else '.then(this._mAll)'}"
			else if d._elWrapper is 'iterator'
				unless isNative
					op= "this._it(#{op});"
			else unless isNative
				throw new Error 'Missing ".toArray", ".iterator" or ".native"'
			# return
			op
	# find one
	findOne: _QueryGenCreate
		name: 'findOne'
		options: _createFindOptions
		fx: (d, options)->
			op= "return this.c.findOne(#{d._query}#{options})"
			unless d._native
				op= "#{op}.then(this._m)"
			op
	# find one and delete
	findOneAndDelete: _QueryGenCreate
		name: 'findOneAndDelete'
		options: 'projection,sort,maxTimeMS,session'.split ','
		fx: (d, options)->
			op= "this.c.findOneAndDelete(#{d._query}#{options})"
			unless d._native
				op= "#{op}#{findAndModifyCb}"
			return op
	# find one and replace
	replaceWith: _QueryGenCreate
		name: 'findOneAndReplace'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session'.split ','
		fx: (d, options)->
			op= "this.c.findOneAndReplace(#{d._query}, #{d._replaceWith}#{options})"
			unless d._native
				op= "#{op}#{findAndModifyCb}"
			return op
			
	# find one and update
	updateWith: _QueryGenCreate
		name: 'findOneAndUpdate'
		options: 'projection,sort,maxTimeMS,upsert,returnOriginal,session,arrayFilters'.split ','
		fx: (d, options)->
			op= "this.c.findOneAndUpdate(#{d._query}, #{d._updateWith}#{options})"
			unless d._native
				op= "#{op}#{findAndModifyCb}"
			return op
	###
	# DELETE DOCUMENTS
	###
	deleteMany: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "this.deleteMany(#{d._query}#{options})"
	deleteOne: _QueryGenCreate
		options: 'w,wtimeout,j,session'.split ','
		fx: (d, options)-> "this.c.deleteOne(#{d._query}#{options})"
	###
	# INSERT DOCUMENTS
	###
	insertOne: _QueryGenCreate
		name: 'insertOne'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "this.c.insertOne(#{d._inserts[0]}#{options})"
	insertMany: _QueryGenCreate
		name: 'insertMany'
		options: 'w,wtimeout,j,serializeFunctions,forceServerObjectId,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "this.c.insertMany(#{_QueryGenLoadParam d._inserts}#{options})"
	###
	# REPLACE DOCUMENTS
	###
	replaceOne: _QueryGenCreate
		name: 'replaceOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,session'.split ','
		fx: (d, options)-> "this.c.replaceOne(#{d._query}, #{d._doc}#{options})"
	###
	# UPDATE DOCUMENTS
	###
	updateMany: _QueryGenCreate
		name: 'updateMany'
		options: 'upsert,w,wtimeout,j,arrayFilters,session'.split ','
		fx: (d, options)-> "this.c.updateMany(#{d._query}, #{d._update}#{options})"
	updateOne: _QueryGenCreate
		name: 'updateOne'
		options: 'upsert,w,wtimeout,j,bypassDocumentValidation,arrayFilters,session'.split ','
		fx: (d, options)-> "this.c.updateOne(#{d._query}, #{d._update}#{options})"

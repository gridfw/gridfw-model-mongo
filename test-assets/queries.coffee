MongoModelRepo= require '..'
MongoRepo= new MongoModelRepo()


console.log '>> Test queries'

# find
# console.log '>> FIND'

# simple
op= {name:'khalid'}
# op= '{name:$1, age: {$le: $2}}'
console.log "aggregate >>", MongoRepo.aggregate([$match: op]).explain.timeout(524525).toString()
console.log "bulkwrite >>", MongoRepo.bulkwrite([op]).toString()
console.log "count >>", MongoRepo.count(op).toString()
console.log "exists >>", MongoRepo.exists(op).toString()
console.log "deleteMany >>", MongoRepo.deleteMany(op).toString()
console.log "deleteOne >>", MongoRepo.deleteOne(op).toString()
console.log "distinct >>", MongoRepo.distinct('field', op).toString()
console.log "findMany >>", MongoRepo.findMany(op).toString()
console.log "findOne >>", MongoRepo.findOne(op).toString()
console.log "findOneAndDelete >>", MongoRepo.findOneAndDelete(op).toString()
console.log "findOneAndReplace >>", MongoRepo.findOneAndReplace(op, {echo:1}).toString()
console.log "findOneAndUpdate >>", MongoRepo.findOneAndUpdate(op, {$set:{cc:512}}).toString()
console.log "insertOne >>", MongoRepo.insertOne(op).toString()
console.log "insertMany >>", MongoRepo.insertMany([op]).toString()
console.log "replaceOne >>", MongoRepo.replaceOne(op, {kk:5}).toString()
console.log "updateMany >>", MongoRepo.updateMany(op, {$set:{oo:525}}).toString()
console.log "updateOne >>", MongoRepo.updateOne(op, {$set:{pp:85}}).toString()

# skip
# console.log ">>"
# # fx= MongoRepo.find('{name:$1, age: {$le: $2}}').skip(2).limit(3).sort({name:1}).fields({name:1, lastName:1}).hint({kk:1}).min(51).max(5215).comment('hello')
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').skip('$3').limit('$4').sort('$5').fields('$6').comment('$7').explain.tailable.raw.partial
# console.log fx.build().toString()

# count
# console.log ">>"
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').skip(3).limit(52).count
# console.log fx.build().toString()

# distinct
# console.log ">>"
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').distinct('name')
# console.log fx.build().toString()

# # updateWith
# console.log ">>"
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').updateWith('$3')
# console.log fx.build().toString()

# # replaceWith
# console.log ">>"
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').replaceWith('$3').new
# console.log fx.build().toString()

# # replaceWith
# console.log ">>"
# fx= MongoRepo.find('{name:$1, age: {$le: $2}}').timeout('$2').remove
# console.log fx.build().toString()

# Update
# console.log ">> Update"
# # fx= MongoRepo.update('{name: $1}', '{b:$2}').upsert
# fx= MongoRepo.update('{name: $1}', '{b:$2}').upsert.limit(1)
# console.log fx.build().toString()

# # Delete
# console.log ">> Delete"
# # fx= MongoRepo.delete('$1')
# fx= MongoRepo.delete('{name:$1}').limit(1)
# console.log fx.build().toString()

# # Replace
# console.log ">> Replace"
# # fx= MongoRepo.replaceOne('$1', '$2')
# fx= MongoRepo.replaceOne('{name:$1}', '$2').upsert
# console.log fx.build().toString()

# # Aggregation
# console.log ">> Aggregation"
# # fx= MongoRepo.aggregate.pipe('$3').raw
# # fx= MongoRepo.aggregate.pipeAll('$3')
# # fx= MongoRepo.aggregate.pipe('$1').pipe('$2').raw
# # fx= MongoRepo.aggregate.pipeAll('$3').pipe('$4').pipe('$6').pipeAll('$1').pipe("$2")
# fx= MongoRepo.aggregate.pipe('$1').pipe('$2').pipeAll('$3')
# console.log fx.build().toString()

# # Bulkwrite
# console.log ">> Bulkwrite"
# # fx= MongoRepo.bulkWrite.write('$3')
# # fx= MongoRepo.bulkWrite.writeAll('$3')
# # fx= MongoRepo.bulkWrite.write('$1').write('$2')
# # fx= MongoRepo.bulkWrite.writeAll('$3').write('$4').write('$6').writeAll('$1').write("$2")
# fx= MongoRepo.bulkWrite.write('$1').write('$2').writeAll('$3')
# console.log fx.build().toString()

# # insert
# console.log ">> Insert"
# # fx= MongoRepo.insert('$1')
# # fx= MongoRepo.insert('$1').forceServerObjectId
# # fx= MongoRepo.insertAll('$1')
# # fx= MongoRepo.insertAll('$1').forceServerObjectId
# # fx= MongoRepo.insert('$1').insert('$2').insertAll('$3')
# # fx= MongoRepo.insert('$3').insert('$4').insert('$6').insertAll('$1').insert("$2")
# fx= MongoRepo.insertAll('$3').insert('$4').insert('$6').insertAll('$1').insert("$2")
# console.log fx.build().toString()
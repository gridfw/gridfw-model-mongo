MongoModelRepo= require '..'
db= new MongoModelRepo()


console.log '>> Test queries'

# find
# console.log '>> FIND'

# # simple
op= {name:db.params.vl}
# # op= '{name:$1, age: {$le: $2}}'
# console.log "aggregate >>", db.params('vl').aggregate([$match: op]).explain.timeout(db.params['timeout + 6666']).toArray.toString()
# console.log "bulkwrite >>", db.params('vl').bulkwrite([$match: name: db.params['substr(vl) + 5']]).toString()
# console.log "count >>", db.params('vl=5').count(op).timeout(0).toString()
# console.log "exists >>", db.params('vl').exists(op).toString()
# console.log "deleteMany >>", db.params('vl').deleteMany(op).toString()
# console.log "deleteOne >>", db.params('vl').deleteOne(op).toString()
# console.log "distinct >>", db.params('vl').distinct('field', op).toString()
# console.log "findMany >>", db.params('vl').findMany(op).toString()
# console.log "findOne >>", db.params('vl').findOne(op).toString()
# console.log "findOneAndDelete >>", db.params('vl').findOneAndDelete(op).toString()
# console.log "findOneAndReplace >>", db.params('vl').findOneAndReplace(op, {echo:1}).toString()
# console.log "findOneAndUpdate >>", db.params('vl').findOneAndUpdate(op, {$set:{cc:512}}).toString()
# console.log "insertOne >>", db.params('vl').insertOne(op).toString()
# console.log "insertMany >>", db.params('vl').insertMany([op]).toString()
# console.log "replaceOne >>", db.params('vl').replaceOne(op, {kk:5}).toString()
# console.log "updateMany >>", db.params('vl').updateMany(op, {$set:{oo:525}}).toString()
# console.log "updateOne >>", db.params('vl').updateOne(op, {$set:{pp:85}}).toString()

console.log "aggregate >>", db.params('vl').man('Aggregation example').aggregate([$match: op]).explain.timeout(db.params['timeout + 6666']).toArray._build()
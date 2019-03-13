# require
Model= require '<%= isProd? "gridfw-model" : "../../gridfw-model" %>'
MongoModelRepo= require '..'

# create user schema
console.log '>> Create user model'
UserModel= Model.from
	name: 'user'
	schema:
		_id: Model.ObjectId
		id: Model.alias '_id'
		firstName: String
		lastName: String

		age: Number
		email: Model.Email
		password: Model.Password
		phone: Model.String.match /^[0-9]+$/

		phones: [
			type: String
			value: String
		]

		methodSample: -> 'hello world'

# create Repo
MongoRepo= new MongoModelRepo()
# create collection
console.log '>> Create user repository'
userRepo= MongoRepo.from
	name: 'user-collection'
	model: UserModel
	indexes:[
		{
			name: 'email-0'
			key:
				name: 1
		}
		{
			name: 'phone-1'
			key:
				phone: 1
				password: -1
			
		}
	]

# find by name
console.log '>> create method: findByName'
userRepo.define findByName: MongoRepo.find '{name: $1}'

console.log '>>', userRepo.findByName

do ->
	try
		console.log '>> Connect to DB'
		await MongoRepo.connect 'mongodb://localhost:27017/test1'

		console.log '>> Create a user'
		user= UserModel {
			firstName: 'khalid'
			lastName: 'RAFIK'
			phone: '0654181111'
			email: 'khalid.rfk@gmail.com'
			password: 'horizon123'
			age: 30
		}

		console.log '>> Save to DB'
		r= await userRepo.save user
		console.log '----> inserted: ', r.result
		console.log '>> user ID: ', user.id

		# get user
		us2= await userRepo.get user.id
		console.log '-- Load user from DB: ', JSON.stringify us2

		# find
		console.log '>> find users by name'
		users= userRepo.findByName 'khalid'
		console.log '---- found: ', users.length
		console.log '---- ', JSON.stringify users

		console.log '>> Disconnect from DB'
		await MongoRepo.close()
		console.log '>> End.'
	catch err
		console.error 'Caught error>> ', err
		MongoRepo.close()
	


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
		userRepo.save user

		console.log '>> Disconnect from DB'
		await MongoRepo.close()
		console.log '>> End.'
	catch err
		console.error 'Caught error>> ', err
		MongoRepo.close()
	


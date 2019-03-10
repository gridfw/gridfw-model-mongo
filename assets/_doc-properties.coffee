###*
 * Doc properties
###
_SAVE_DEFAULT_OPTIONS=
	cascade: off # do not save references
_docProperties=
	###*
	 * Save document to DB
	 * @param {boolean} options.cascade - when true, save all sub documents too
	###
	save: (options)->
		options ?= _SAVE_DEFAULT_OPTIONS
		

# ------------------------------------------
UserModel= Model.from
	name: 'user'
	schema: {}

UserRepo= MongoRepository.from
	name: 'user'
	indexes: []

# do
user= UserModel {...}

# save
UserRepo.save user

# update
UserRepo.update user, {$set: {name: 'khalid'}}

# select
user1= UserModel await UserRepo.get 'id'
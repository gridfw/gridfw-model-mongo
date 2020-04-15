# gridfw-model-mongo
Mongo middleware for gridfw-model

## Include the middleware
```javascript
// Create Mongo middleware
const MongoClass=	require('gridfw-model-mongo');
const db= new MongoClass({
	prefix: 'g-' // Enable to autoremove removed indexes without affecting added ones manually
});

// Connect to Mongo
db.connect('mongo://uri/database')
	.then(function(){console.log('---Connected')})
	.catch(function(err){console.error('---Got error: ', err)});
```

The middleware will add a new Model type: ObjectId
You can use it as: Model.ObjectId

## Create new Collection (repository)
```javascript
db.from({
	name: 'MyCollection', // collection name
	model: MyModel, // @optional, link to your model
	indexes: [
		{index1},
		//...
		{indexn},
	],
	define: function(nativeCollection, model){
		return {
			myMethod: function(){}
			myMethod2: function(){}
			//....
		}
	}

});
```

## Full example
```javascript
	// Load APIs
	const ModelClass= require('gridfw-model');
	const MongoClass= require ('gridfw-model-mongo');

	// Create factories
	const Model= new ModelClass();
	const db= new MongoClass({prefix: 'g-'});

	// Create user model
	const UserModel= Model.define('User',{
		_id:	Model.ObjectId,
		email:	String,
		name:	String,
		age:	Number
	});

	// Create user respository
	const userRepository= db.from({
		name: 'users',
		model:	UserModel,
		indexes: [
			{
				// Index name: change index name each time you change the index options
				// Tip: use an increment digit as follow: g-email-1 ... g-email-n
				name: 'g-email-0',
				// Your mongo index kies (@see mongo documentation)
				key: {
					email: 1
				},
				unique: true, // @optional, Mongo flag
				partialFilterExpression: { // @optional, Mongo partial expression
					email: {$exists: true}
				}
			}
		],
		define: function(userRepository, UserModel){
			return {
				// Return plain object
				findById: function(id){ return userRepository.findOne({_id: id}); }

				// Return userModel
				findById2: function(id){
					doc= await userRepository.findOne({_id: id});
					doc= userModel.fromDB(doc);
					return doc;
				}
			}
		}
	});
```
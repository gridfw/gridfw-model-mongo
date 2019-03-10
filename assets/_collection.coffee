###*
 * Mongo Collection
###
class CollectionRepository
	###*
	 * Collection mapper
	 * @private @param {MongoRepository} _MR - parent mongo repository
	 * @param  {String} name  - Collection name
	 * @param  {Model} Model  - Model representing collection architecture
	 * @param  {List} indexes - list of used indexes
	###
	constructor: (@_MR, @name, @Model, @indexes)->

	###*
	 * Get document by id
	###
	get: (selector, options)->


	###*
	 * Find one document, alias to get
	###
	findOne: (selector, options)->

	###*
	 * CallBack when disconnect
	 * @private
	###
	_whenDisconnect:->
		# remove native collection
		_defineProperty this, 'Collection',
			value: null
			configurable: on
		return



# Getters
_defineProperties CollectionRepository.prototype,
	# native mongo collection
	Collection:
		get: ->
			db= @_MR.db
			throw new Error 'Not connected!' unless db
			collection = db.collection @name
			_defineProperty this, 'Collection',
				value: collection
				configurable: on
			collection

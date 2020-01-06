### iterator wrapper ###
# class CursorIterator
# 	constructor: (cursor, modelfetcher)->
# 		_defineProperties this,
# 			cursor: value: cursor
# 			_fetch: value: modelfetcher
# 		return
# 	# next
# 	next: -> @cursor.next().then @_fetch
# 	hasNext: -> @cursor.hasNext()
# 	isClosed: -> @cursor.isClosed()
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
		

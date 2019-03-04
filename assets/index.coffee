###*
 * MongoDB plugin for Gridfw-model
###

Model = require <%= isProd? '../../gridfw-model': 'gridfw-model'

#=include _doc-properties.coffee

# add
Model.plugin
	doc: _docProperties
thinky = require 'thinky'
instance = null

create = (options) ->
	if instance then instance
	instance = thinky options

module.exports = create

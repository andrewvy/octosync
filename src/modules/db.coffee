r = require 'rethinkdb'
thinky = require 'thinky'
{EventEmitter} = require 'events'

module.exports = class Database extends EventEmitter
	Models: {}
	constructor: (@options) ->
		@Thinky = thinky @getConfig()
		@Models = @setupModels()

	getConfig: ->
		host: @options.db_host
		port: @options.db_port
		db: @options.db_name

	getUserById: (id) -> #
	getIssueById: (id) -> #

	setupModels: ->
		User: require('../models/user')(@Thinky)
		Label: require('../models/label')(@Thinky)
		Issue: require('../models/issue')(@Thinky)

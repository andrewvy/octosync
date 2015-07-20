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

	setupModels: ->
		User: require('../models/user')(@Thinky)
		Issue: require('../models/issue')(@Thinky)

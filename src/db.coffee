r = require 'rethinkdb'
{EventEmitter} = require 'events'

module.exports = class Database extends EventEmitter
	constructor: (@options) ->
		@connection = null

		@connect()

	getConfig: ->
		host: @options.db_host
		port: @options.port

	connect: ->
		r.connect @getConfig(), (err, conn) =>
			throw err if err

			@connection = conn
			@connection.use @options.db_name
			@onConnection()

	onConnection: ->
		@emit 'connection'

r = require 'rethinkdb'
{EventEmitter} = require 'events'

module.exports = class Database extends EventEmitter
	constructor: (@options) ->
		@connection = null

		@connect()

	getConfig: ->
		host: @options.db_host
		port: @options.db_port

	connect: ->
		r.connect @getConfig(), (err, conn) =>
			throw err if err

			@connection = conn
			@connection.use @options.db_name
			@onConnection()

	onConnection: ->
		console.log "Successfully connected to RethinkDB on Port %d", @options.db_port
		@emit 'connection'

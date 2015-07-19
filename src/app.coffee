_ = require 'lodash'

Database = require './db'

module.exports = class App
	defaults:
		db_host: "localhost"
		db_name: "octosync"
		db_port: 28015
		token: ""
		username: ""
		repository: ""

	constructor: (opts) ->
		throw new Error "Must pass in a valid OAuth GitHub token" if !opts.token
		throw new Error "Must pass in a GitHub username" if !opts.username
		throw new Error "Must pass in a GitHub repository" if !opts.repository

		@options = _.defaults opts, @defaults

		@_setupDatabase()
		@_setupDatabaseListeners()

	_setupDatabase: ->
		@db = new Database @options

	_setupDatabaseListeners: ->
		@db.on 'connection', @connected

	connected: ->
		console.log "Successfully connected to DB."

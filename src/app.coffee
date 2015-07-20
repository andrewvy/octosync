_ = require 'lodash'

Database = require './modules/db'
Webhook = require './modules/webhook'
Sync = require './modules/sync'

module.exports = class App
	defaults:
		db_host: "localhost"
		db_name: "octosync"
		db_port: 28015
		webhook_path: "/octosync"
		webhook_port: 27070
		webhook_secret: ""
		token: ""
		username: ""
		repository: ""

	constructor: (opts) ->
		throw new Error "Must pass in a valid OAuth GitHub token" if !opts.token
		throw new Error "Must pass in a GitHub username" if !opts.username
		throw new Error "Must pass in a GitHub repository" if !opts.repository

		@options = _.defaults opts, @defaults

		@db = @_setupDatabase()

		@db.on 'connection', =>
			@webhook = @_setupWebhook()
			@sync = @_setupSync()

	_setupDatabase: -> new Database @options
	_setupWebhook: -> new Webhook @options
	_setupSync: -> new Sync @_syncOptions()
	_syncOptions: ->
		db: @db
		webhook: @webhook
		options: @options

{EventEmitter} = require 'events'
_ = require 'lodash'

Database = require './modules/db'
Webhook = require './modules/webhook'
Sync = require './modules/sync'

module.exports = class App extends EventEmitter
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

	start: ->
		@db = @_setupDatabase()
		@webhook = @_setupWebhook()
		@sync = @_setupSync()

	# Sync Methods
	syncIssues: -> @sync.syncIssues()
	syncUsers: -> @sync.syncUsers()
	syncLabels: -> @sync.syncLabels()

	# Query Methods
	getIssueById: (id) -> @db.getIssueById(id)
	getUserById: (id) -> @db.getUserById(id)

	_setupDatabase: -> new Database @options
	_setupWebhook: -> new Webhook @options
	_setupSync: -> new Sync @_syncOptions()
	_syncOptions: ->
		db: @db
		webhook: @webhook
		options: @options

{EventEmitter} = require 'events'
Github = require 'github'
_ = require 'lodash'

module.exports = class Sync extends EventEmitter
	constructor: (opts) ->
		{ @db, @webhook, @options } = opts

		throw new Error "DB was not correctly instantiated." if !@db
		throw new Error "Webhook was not correctly instantiated." if !@webhook
		throw new Error "No Github Token found in options." if _.isEmpty(@options.token)

		@github_client = @getClient()
		@github_client.authenticate
			type: "oauth"
			token: @options.token

	getClient: -> new Github { version: "3.0.0" }

	syncIssues: -> #
	syncIssue: (issue_id) -> #

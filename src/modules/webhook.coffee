{EventEmitter} = require 'events'
GithubHook = require 'githubhook'

module.exports = class Webhook extends EventEmitter
	events: ['issue_comment', 'issues']
	constructor: (opts) ->
		{ @db, @options } = opts

		throw new Error "DB was not correctly instantiated." if !@db

		options =
			path: @options.webhook_path
			port: @options.webhook_port
			secret: @options.webhook_secret

		@github = GithubHook(options)

		@_setupGithubListener()

	_setupGithubListener: ->
		console.log "Github Webhook '%s' listening on Port: %d", @options.webhook_path, @options.webhook_port
		@github.listen()

		@github.on '*', (event, repo, ref, data) ->
			if event in @events
				@[event](data)

	issue_comment: (data) ->
		issue = @db.formatIssue data.issue
		@db.Models.Issue.save(issue, { conflict: "update" }).then (models) ->
			deferred.resolve data

	issues: (data) ->
		issue = @db.formatIssue data.issue
		@db.Models.Issue.save(issue, { conflict: "update" }).then (models) ->
			deferred.resolve data

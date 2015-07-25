{EventEmitter} = require 'events'
GithubHook = require 'githubhook'

module.exports = class Webhook extends EventEmitter
	events: ['issue_comment', 'issues', 'deployment']
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
			console.log "GOT EVENT: #{event}"
			if event in ['issue_comment', 'issues', 'deployment']
				@[event](data)

	issue_comment: (data) ->
		deferred = Q.defer()
		issue = @db.formatIssue data.issue
		@db.Models.Issue.save(issue, { conflict: "update" }).then (models) ->
			deferred.resolve data

		deferred.promise

	issues: (data) ->
		deferred = Q.defer()
		issue = @db.formatIssue data.issue
		@db.Models.Issue.save(issue, { conflict: "update" }).then (models) ->
			deferred.resolve data

		deferred.promise

	deployment: (data) ->
		deferred = Q.defer()
		deployment = @db.formatDeployment data
		@db.Models.Deployment.save(deployment, { conflict: "update" }).then (models) ->
			deferred.resolve data

		deferred.promise

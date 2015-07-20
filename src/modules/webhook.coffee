{EventEmitter} = require 'events'
GithubHook = require 'githubhook'

module.exports = class Webhook extends EventEmitter
	events: ['issue_comment', 'issues', 'pull_request']
	constructor: (@options) ->
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
			@emit event, @_formatEvent(event, repo, ref, data)

	_formatEvent: (repo, ref, data) -> ""

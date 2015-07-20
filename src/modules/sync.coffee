{EventEmitter} = require 'events'
Github = require 'github'
Q = require 'q'
_ = require 'lodash'

module.exports = class Sync extends EventEmitter
	constructor: (opts) ->
		{ @App, @webhook, @options } = opts

		throw new Error "Webhook was not correctly instantiated." if !@webhook
		throw new Error "No Github Token found in options." if _.isEmpty(@options.token)

		@github_client = @getClient()
		@github_client.authenticate
			type: "oauth"
			token: @options.token

	getClient: -> new Github { version: "3.0.0" }

	syncIssues: ->
		# Syncs all issues

	syncIssue: (issue_id) ->
		# Syncs just a single issue

	defaults: ->
		user: @options.username
		repo: @options.repository

	getNumberOfIssues: (options={}) ->
		deferred = Q.defer()

		opts = _.defaults @defaults(), options

		@github_client.repos.get opts, (err, data) ->
			if (err)
				deferred.reject(err)
			else
				deferred.resolve(data['open_issues_count'])

		deferred.promise

	getIssues: (options={}) ->
		deferred = Q.defer()

		opts = _.defaults @defaults(), options

		@github_client.issues.repoIssues opts, (err, data) ->
			if (err)
				deferred.reject(err)
			else
				deferred.resolve(data)

		deferred.promise

	getAllIssues: ->
		deferred = Q.defer()

		@getNumberOfIssues().done (issue_count) =>
			times = Math.ceil(issue_count / 50)
			promises = for i in [0..times]
				do (i) =>
					@getIssues({ per_page: 50, page: i })

			Q.allSettled(promises).then (results) ->
				issues = _.flatten _.map results, (result) ->
					return result.value

				deferred.resolve(data)
			, (err) ->
				deferred.reject(err)

		deferred.promise

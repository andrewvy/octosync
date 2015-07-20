{EventEmitter} = require 'events'
Github = require 'github'
Q = require 'q'
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

		@syncUsers()
		@syncLabels()
		@syncIssues()

	defaults: ->
		user: @options.username
		repo: @options.repository

	getClient: -> new Github { version: "3.0.0" }

	syncUsers: ->
		console.time "sync_users"

		@getAllUsers().then (users) ->
			console.timeEnd "sync_users"
			console.log "Finished syncing users."
		, (err) ->
			console.timeEnd "sync_users"
			console.error "Error syncing users.", err

	syncLabels: ->
		console.time "sync_labels"

		@getAllLabels({per_page: 100}).then (labels) ->
			console.timeEnd "sync_labels"
			console.log "FInished syncing labels."
		, (err) ->
			console.timeEnd "sync_labels"
			console.error "Error syncing labels.", err

	syncIssues: ->
		console.time "sync_issues"

		@getAllIssues().then (issues) ->
			console.timeEnd "sync_issues"
			console.log "Finished syncing issues."
		, (err) ->
			console.timeEnd "sync_issues"
			console.error "Error syncing issues.", err

	# -----------
	# Getters
	# -----------

	getAllUsers: (options={}) ->
		deferred = Q.defer()
		opts = _.defaults @defaults(), options

		@github_client.repos.getContributors opts, (err, data) =>
			if (err)
				deferred.reject err
			else
				@db.Models.User.save(data, { conflict: "update" }).then (models) ->
					deferred.resolve data

		deferred.promise

	getAllLabels: (options={}) ->
		deferred = Q.defer()
		opts = _.defaults @defaults(), options

		@github_client.issues.getLabels opts, (err, data) =>
			if (err)
				deferred.reject err
			else
				@db.Models.Label.save(data, { conflict: "update" }).then (models) ->
					deferred.resolve data

		deferred.promise
		deferred.promise

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

		@github_client.issues.repoIssues opts, (err, data) =>
			if (err)
				deferred.reject(err)
			else
				formatted_issues = _.map(data, @db.formatIssue)
				@db.Models.Issue.save(formatted_issues, {conflict: "update"}).then (models) ->
					deferred.resolve(models)
		deferred.promise

	getAllIssues: ->
		deferred = Q.defer()

		@getNumberOfIssues().done (issue_count) =>
			times = Math.ceil(issue_count / 50)
			promises = for i in [0..times]
				do (i) =>
					@getIssues({ per_page: 50, page: i })

			Q.all(promises).then (results) ->
				deferred.resolve(results)
			, (err) ->
				deferred.reject(err)

		deferred.promise

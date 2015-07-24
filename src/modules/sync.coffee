{EventEmitter} = require 'events'
Github = require 'github'
Q = require 'q'
_ = require 'lodash'

module.exports = class Sync extends EventEmitter
	constructor: (opts) ->
		{ @db, @options } = opts

		throw new Error "DB was not correctly instantiated." if !@db
		throw new Error "No Github Token found in options." if _.isEmpty(@options.token)

		@github_client = @getClient()
		@github_client.authenticate
			type: "oauth"
			token: @options.token

		Q.all([@syncUsers(), @syncLabels(), @syncMilestones()]).then (values) =>
			users = _.pluck values[0], 'id'
			labels = _.pluck values[1], 'name'
			milestones = _.pluck values[2], 'id'

			@syncIssues(users, labels, milestones)

	defaults: ->
		user: @options.username
		repo: @options.repository

	getClient: -> new Github { version: "3.0.0" }

	syncUsers: ->
		deferred = Q.defer()
		console.time "sync_users"

		@getAllUsers().then (users) ->
			console.timeEnd "sync_users"
			deferred.resolve(users)
		, (err) ->
			console.timeEnd "sync_users"
			console.error "Error syncing users.", err
			deferred.reject(err)

		deferred.promise

	syncLabels: ->
		deferred = Q.defer()
		console.time "sync_labels"

		@getAllLabels({per_page: 100}).then (labels) ->
			console.timeEnd "sync_labels"
			deferred.resolve(labels)
		, (err) ->
			console.timeEnd "sync_labels"
			console.error "Error syncing labels.", err
			deferred.reject(err)

		deferred.promise

	syncIssues: (users, labels, milestones) ->
		deferred = Q.defer()
		console.time "sync_issues"

		@getAllIssues(users, labels, milestones).then (issues) ->
			console.timeEnd "sync_issues"
			deferred.resolve(issues)
		, (err) ->
			console.timeEnd "sync_issues"
			console.error "Error syncing issues.", err
			deferred.reject(err)

		deferred.promise

	syncMilestones: ->
		deferred = Q.defer()
		console.time "sync_milestones"

		@getAllMilestones().then (milestones) ->
			console.timeEnd "sync_milestones"
			deferred.resolve(milestones)
		, (err) ->
			console.timeEnd "sync_milestones"
			console.error "Error syncing milestones.", err
			deferred.reject(err)

		deferred.promise

	# -----------
	# Getters
	# -----------

	getAllMilestones: (options={}) ->
		deferred = Q.defer()
		opts = _.defaults @defaults(), options

		@github_client.issues.getAllMilestones opts, (err, data) =>
			if (err)
				deferred.reject err
			else
				@db.Models.Milestone.save(data, { conflict: "update" }).then (models) ->
					deferred.resolve data

		deferred.promise


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

		times = 5
		promises = for i in [0..times]
			do (i) =>
				opts.page = i
				@github_client.issues.getLabels opts, (err, data) =>
					if (err)
						deferred.reject err
					else
						formatted_labels = _.map(data, @db.formatLabel)
						@db.Models.Label.save(formatted_labels, { conflict: "update" }).then (models) ->
							deferred.resolve data

		Q.all(promises).then (results) ->
			deferred.resolve(results)
		, (err) ->
			deferred.reject(err)

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

	getIssues: (options={}, users, labels, milestones) ->
		deferred = Q.defer()
		opts = _.defaults @defaults(), options

		@github_client.issues.repoIssues opts, (err, data) =>
			if (err)
				deferred.reject(err)
			else
				formatted_issues = _.map data, (issue) =>
					@db.formatIssue issue

				formatted_issues = _.filter formatted_issues, (issue) =>
					issue.creator_id in users and issue?.assignee_id in users and issue?.milestone_id in milestones

				@db.Models.Issue.save(formatted_issues, {conflict: "update"}).then (models) ->
					deferred.resolve(models)
		deferred.promise

	getAllIssues: (users, labels, milestones) ->
		deferred = Q.defer()

		@getNumberOfIssues().done (issue_count) =>
			times = Math.ceil(issue_count / 50)
			promises = for i in [0..times]
				do (i) =>
					@getIssues({ per_page: 50, page: i }, users, labels, milestones)

			Q.all(promises).then (results) ->
				deferred.resolve(results)
			, (err) ->
				deferred.reject(err)

		deferred.promise

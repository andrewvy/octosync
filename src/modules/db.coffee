r = require 'rethinkdb'
O = require '../utils/Object'
thinky = require 'thinky'
{EventEmitter} = require 'events'

module.exports = class Database extends EventEmitter
	Models: {}
	constructor: (@options) ->
		@Thinky = thinky @getConfig()
		@Models = @setupModels()

	getConfig: ->
		host: @options.db_host
		port: @options.db_port
		db: @options.db_name

	getUserById: (id) -> #
	getIssueById: (id) -> #

	setupModels: ->
		User: require('../models/user')(@Thinky)
		Label: require('../models/label')(@Thinky)
		Issue: require('../models/issue')(@Thinky)
		Milestone: require('../models/milestone')(@Thinky)
		Deployment: require('../models/deployment')(@Thinky)

	formatIssue: (data) ->
		obj = O.redefineProperty data, "user", "creator"

		if obj.assignee
			obj.assignee_id = obj.assignee.id

		if obj.milestone
			obj.milestone_id = obj.milestone.id

		if obj.labels?.length
			obj.label_ids = []

			for label in obj.labels
				obj.label_ids.push label.name

		obj.creator_id = obj.user.id

		# Clean up relations
		delete obj.user
		delete obj.assignee
		delete obj.milestone

		obj

	formatLabel: (data={}) ->
		data.id = data.name
		data

	formatDeployment: (data={}) ->
		data.creator_id = data.creator?.id
		delete data.creator
		data

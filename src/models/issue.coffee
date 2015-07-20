Issue = null

module.exports = (thinky) ->
	if Issue then return Issue

	User = require('./user')(thinky)
	Label = require('./label')(thinky)

	Issue = thinky.createModel "Issue",
		id: Number
		html_url: String
		number: Number
		state: String
		title: String
		body: String
		comments: Number
		closed_at: String
		updated_at: String
		assignee_id: Number
		creator_id: Number

	Issue.belongsTo User, "assignee", "assignee_id", "id"
	Issue.belongsTo User, "creator", "creator_id", "id"
	Issue.hasAndBelongsToMany Label, "labels", "id", "id"

Issue = null

module.exports = (thinky) ->
	if Issue then return Issue

	User = require('./user')(thinky)
	Label = require('./label')(thinky)
	Milestone = require('./milestone')(thinky)

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
		milestone_id: Number

	Issue.belongsTo User, "assignee", "assignee_id", "id"
	Issue.belongsTo User, "creator", "creator_id", "id"
	Issue.belongsTo Milestone, "milestone", "milestone_id", "id"
	Issue.hasAndBelongsToMany Label, "labels", "id", "id"

	User.hasMany Issue, "assigned_issues", "id", "assignee_id"
	User.hasMany Issue, "created_issues", "id", "creator_id"

	Issue

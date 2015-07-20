Milestone = null

module.exports = (thinky) ->
	if Milestone then return Milestone
	User = require('./user')(thinky)

	Milestone = thinky.createModel "Milestone",
		id: Number
		html_url: String
		number: Number
		title: String
		description: String
		creator_id: Number
		open_issues: Number,
		closed_issues: Number,
		created_at: String
		closed_at: String
		due_on: String

	Milestone.belongsTo User, "creator", "creator_id", "id"

	Milestone

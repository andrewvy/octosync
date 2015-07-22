User = null

module.exports = (thinky) ->
	if User then return User

	Issue = require('./Issue')(thinky)

	User = thinky.createModel "User",
		id: Number
		login: String
		avatar_url: String
		html_url: String
		name: String

	User.hasMany Issue, "assigned_issues", "id", "assignee_id"
	User.hasMany Issue, "created_issues", "id", "creator_id"

	User

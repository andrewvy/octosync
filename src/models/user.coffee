User = null

module.exports = (thinky) ->
	if User then return User

	User = thinky.createModel "User",
		id: Number
		login: String
		avatar_url: String
		html_url: String
		name: String

	User

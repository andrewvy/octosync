module.exports = (thinky) ->
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

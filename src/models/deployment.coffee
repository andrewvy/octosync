Deployment = null

module.exports = (thinky) ->
	if Deployment then return Deployment

	User = require('./user')(thinky)

	Deployment = thinky.createModel "Deployment",
		id: Number
		url: String
		sha: String
		ref: String
		task: String
		environment: String
		creator_id: Number
		created_at: String
		updated_at: String

	Deployment.belongsTo User, "creator", "creator_id", "id"

	Deployment

Deployment = null

module.exports = (thinky) ->
	if Deployment then return Deployment

	User = require('./user')(thinky)

	r = thinky.r
	type = thinky.type

	Deployment = thinky.createModel "Deployment",
		id: type.number()
		url: type.string()
		sha: type.string()
		ref: type.string()
		task: type.string()
		environment: type.string()
		creator_id: type.number()
		created_at: type.string()
		updated_at: type.string()
		deployed_at: type.date().default(r.now())

	Deployment.belongsTo User, "creator", "creator_id", "id"

	Deployment

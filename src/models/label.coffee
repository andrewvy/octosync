Label = null

module.exports = (thinky) ->
	if Label then return Label

	Label = thinky.createModel "Label",
		url: String
		name: String
		color: String

	Label.ensureIndex "name"
	Label

module.exports =
	redefineProperty: (o, old_key, new_key) ->
		if (old_key is not new_key)
			Object.defineProperty o, new_key, Object.getOwnPropertyDescriptor(o, old_key)
			delete o[old_key]

		o

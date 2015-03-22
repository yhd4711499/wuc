@Tools = {}
@Tools.autoDefault = (defaultValue, doc) ->
	return defaultValue if doc.isInsert
	return {$setOnInsert: defaultValue} if doc.isUpsert
	return doc.value
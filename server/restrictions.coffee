Items.allow
	insert: (userId, doc) ->
		userId?
	update: (userId, doc, fields, modifier) ->
		userId?
	remove: (userId, doc) ->
		userId?
	fetch: ['owner']

Games.allow
	insert: (userId, doc) ->
		userId?
	update: (userId, doc) ->
		userId && (doc.status == 0) && (doc._ownerId == userId)
	remove: (userId, doc) ->
		userId && (doc.status == 0) && (doc._ownerId == userId)
	
	
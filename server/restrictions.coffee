Items.allow
	insert: (userId, doc) ->
		userId? && Meteor.user().admin?
	update: (userId, doc, fields, modifier) ->
		userId? && Meteor.user().admin?
	remove: (userId, doc) ->
		userId? && Meteor.user().admin?
	fetch: ['owner']

Games.allow
	insert: (userId, doc) ->
		userId?
	update: (userId, doc) ->
		(userId && (doc.status == 0) && (doc._ownerId == userId)) || Meteor.user().admin?
	remove: (userId, doc) ->
		(userId && (doc.status == 0) && (doc._ownerId == userId)) || Meteor.user().admin?
	fetch: ['_ownerId', 'status']
	
	
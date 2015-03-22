Template.new.created = () ->
	this.autorun((() ->

		# Meteor.call('newGame', 
		# 	(err, doc) -> 
		# 		if err 
		# 			Router.back()
		# 		else
		# 			Session.set("gameId", doc)
		# 			subscription = Meteor.subscribe('games', doc);
		# );
	).bind(this))


Template.new.helpers
	game: ->
		# return Games.findOne({_id: Session.get("gameId")})
		name: "Room 1",

AutoForm.hooks 'games-new-form':
  onSuccess: (operation, result, template) ->
    IonModal.close()
    Router.go '/play/' + result
    return
  onError: (operation, error, template) ->
    return
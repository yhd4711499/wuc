Meteor.publish 'games', () ->
 	Games.find()

Meteor.publish 'players', () ->
 	Players.find()

Meteor.publish 'items', () ->
 	Items.find()

Meteor.publish 'alivePlayers', (gameId) -> 
	alivePlayers gameId
Meteor.publish 'awaitingPlayers', (gameId) -> 
	awaitingPlayers gameId
Meteor.publish 'deadPlayers', (gameId) -> 
	deadPlayers gameId

Meteor.publish 'gamelogs', (gameId) ->
	Gamelogs.find({_gameId: gameId})

Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find({ _id: @userId }, fields:
      'admin': 1)
  else
    @ready()
  return

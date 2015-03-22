Meteor.startup ->
	initializing = true


	@Games.find().observe 
		removed: (oldDocument) ->
			Players.remove({_gameId: oldDocument._id})
	
	@Players.find().observe 
		added: (document) ->
			return if initializing
			Games.update
				_id: document._gameId
			,
				$inc:
					players: 1

		changed: (newDocument, oldDocument) ->
			return if initializing
			return if newDocument._gameId == oldDocument._gameId

			Games.update
				_id: oldDocument._gameId
			,
				$inc:
					players: -1
			Games.update
				_id: newDocument._gameId
			,
				$inc:
					players: 1

		removed: (oldDocument) ->
			return if initializing
			Games.update
				_id: oldDocument._gameId
			,
				$inc:
					players: -1

	initializing = false
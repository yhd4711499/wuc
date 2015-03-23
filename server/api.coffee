@timers = {}

Meteor.methods
	joinGame: (gameId) ->
		throw new Meteor.Error("You must login to join a game!") if not this.userId
		existed = Players.findOne
					_userId: @userId
					_gameId: gameId
		if existed
			return existed._id

		ret = Players.upsert
			_userId: this.userId
		,
			$set:
				_userId: this.userId
				_gameId: gameId
				nickname: Meteor.user().profile.nickname
				ready: false
				voted: false
				voteCount: 0
				role: 0
				status: 0
		# Games.update
		# 	_id: gameId
		# ,
		# 	$inc:
		# 		players: 1
		return ret.insertedId

	imNotReady: ->
		n = Players.update
			_userId: @userId
		,
			$set:
				ready: false
		throw new Meteor.Error("Can't find the user") if n is 0

		gameId = Players.findOne({_userId: @userId})._gameId;

		Meteor.call 'gameEnterIdle', gameId

		return n

	imReady: ->
		n = Players.update
			_userId: @userId
		,
			$set:
				ready: true
		throw new Meteor.Error("Can't find the user") if n is 0

		gameId = Players.findOne({_userId: @userId})._gameId;

		if Meteor.call 'canStart', gameId
			Meteor.call 'gameEnterPending', gameId

		return n

	exitGame: (gameId) ->
		throw new Meteor.Error("You must login to join a game!") if not this.userId

		Players.remove
			_userId: this.userId
			_gameId: gameId

		if Players.find({_gameId: gameId}).count() == 0
			gameLog.clear gameId
			return Meteor.call 'gameEnterIdle', gameId

		gameStatus = Games.findOne({_id: gameId}).status

		switch gameStatus
			when 1
				Meteor.call 'gameEnterPending', gameId
			when 2
				uCount = Players.find({_gameId: gameId, role: 1}).count()
				if uCount == 0
					Meteor.call 'gameEnterIdle', gameId
				else if Players.find({_gameId: gameId, role: 0}).count() == 0
					Meteor.call 'gameEnterIdle', gameId
			
		
	canStart: (gameId) ->
		allPlayers = Players.find({_gameId: gameId}, {fields: {ready: 1}}).fetch()
		uCount = Games.findOne({_id: gameId}, {fields: {uCount: 1}}).uCount
		if allPlayers.length <= uCount
			# not enough players
			return false
		notReadyCount = _(allPlayers).reduce(
			(player)->
				return 1 if not player.ready
				return 0
				)
		if notReadyCount != 0
			return false

		return true

	showRound: (gameId) ->
		round = Games.findOne({_id: gameId}, {fields: {round: 1}}).round
		gameLog.p gameId, "目前为第#{round+1}轮投票"

	gameEnterIdle: (gameId) ->
		if timers.hasOwnProperty gameId
			Meteor.clearTimeout timers[gameId]
			delete timers[gameId]
		Games.update
				_id: gameId
			,
				$set:
					status: 0
					round: 0
		gameLog.i gameId, "等待玩家准备"
		Meteor.call 'endGame', gameId

	gameEnterPending: (gameId) ->
		Games.update
				_id: gameId
			,
				$set:
					status: 1
		gameLog.clear gameId
		gameLog.i gameId, "游戏马上开始"
		timer = Meteor.setTimeout(
			-> Meteor.call 'gameEnterPlaying', gameId,
			5 * 1000)

		if timers.hasOwnProperty gameId
			Meteor.clearTimeout timers[gameId]

		timers[gameId] = timer

	gameEnterPlaying: (gameId) ->
		delete timers[gameId]
		Games.update
				_id: gameId
			,
				$set:
					status: 2
					round: 0
		gameLog.clear gameId
		gameLog.i gameId, "游戏已开始"
		Meteor.call 'startGame', gameId

	startGame: (gameId, uCount = 1) ->
		pairs = Items.find().fetch()

		pair = _(pairs).sample(1)[0]

		allId = Players.find({_gameId: gameId}, {fields: {_id: 1}}).fetch()

		uCount ?= Games.findOne({_id: gameId}, {fields: {uCount: 1}}).uCount

		randomIds = _(allId).sample(uCount).map((o)->o._id)
		
		Players.update
			_gameId: gameId
		,
			$set:
				ready: false
				voted: false
				voteCount: 0
				status: 1
				role: 0
				item: pair.common
		,
			multi: true

		Players.update
			_gameId: gameId
			_id:
				$in: randomIds
		,
			$set:
				role: 1
				item: pair.special
		Meteor.call 'showRound',gameId

	endGame: (gameId) ->
		Players.update
			_gameId: gameId
		,
			$set:
				ready: false
		,
			multi: true

	vote: (targetUserId) ->
		throw new Meteor.Error('Sorry but you cannot vote yourself!') if targetUserId == @userId

		voter = Players.findOne
			_userId: @userId
		
		throw new Meteor.Error('You have voted already.') if voter.voted

		gameId = voter._gameId

		# increase votespoll count of target player
		Players.update
			_userId: targetUserId
		,
			$inc:
				voteCount: 1

		# mark voter as voted
		Players.update
			_userId: @userId
		,
			$set:
				voted: true

		# now everyone has voted, let the judge begin
		if Players.find({_gameId: gameId, voted: false, status: 1}).count() == 0
			Meteor.call 'judge', gameId

	judge: (gameId) ->
		Games.update
			_id: gameId
		,
			$inc:
				round: 1

		allPlayers = Players.find
			_gameId: gameId
		,
			fields:
				nickname: 1
				_userId: 1
				voteCount: 1
				role: 1
		.fetch()

		# reset voting state
		Players.update
			_gameId: gameId
		,
			$set:
				voted: false
				voteCount: 0
		,
			multi: true

		# guilty is the guy who got most votes
		# if there more than one person who got most votes
		# re-run this turn.
		max = 0
		guilty = null
		_.each allPlayers, (player) -> 
			if max == player.voteCount
				guilty = null
			else if player.voteCount > max
				max = player.voteCount
				guilty = player

		if guilty == null
			gameLog.p gameId, "没有人死亡，请再次投票"
			Meteor.call 'showRound',gameId
			return

		# may god be with him (or her?)
		Players.update
			_userId: guilty._userId
		,
			$set:
				status: 2

		role = switch guilty.role
			when 0
				'平民'
			when 1
				'卧底'
				
		gameLog.p gameId, "#{guilty.nickname} 已死亡，他是#{role}"

		switch guilty.role
			when 1
				# an undercover was dead
				if Players.find({_gameId: gameId,role: 1, status: 1}).count() == 0
					gameLog.p gameId, "卧底全部被消灭，平民胜利！"
					Meteor.call 'gameEnterIdle', gameId
				else
					Meteor.call 'showRound',gameId
			when 0
				# a common was dead
				count = Players.find({_gameId: gameId,role: 0, status: 1}).count()
				if count != 0
					wCount = Players.find({_gameId: gameId,role: 1, status: 1}).count()
					if wCount >= count
						gameLog.p gameId, "平民人数少于卧底，卧底胜利！"
						Meteor.call 'gameEnterIdle', gameId
					else
						Meteor.call 'showRound',gameId
				else
					gameLog.p gameId, "卧底胜利！"
					Meteor.call 'gameEnterIdle', gameId




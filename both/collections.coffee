@Games = new Mongo.Collection 'games'
@Games.attachSchema new SimpleSchema
  createdAt: 
    type: Date
    autoValue: -> Tools.autoDefault new Date(), this
    optional: true

  _ownerId:
    type: String
    optional: true
    autoValue: -> Tools.autoDefault @userId, this
  # room status
  # 0: idle
  # 1: pendiing
  # 2: playing
  status: 
    type: Number
    defaultValue: 0
    optional: true

  # room name
  name: 
    label: "房间名称"
    unique: true
    type: String
    max: 200

  uCount:
    label: "卧底数目"
    type: Number
    defaultValue: 1
    optional: true
    min: 1
    autoform:
      placeholder: '默认为1'

  password:
    label: "密码"
    type: String
    optional: true
    autoform:
      placeholder: '没用的'

  players:
    type: Number
    autoValue: -> Tools.autoDefault 0, this
    optional: true
    min: 0

  # number of round for voting
  round: 
    type: Number
    min: 0
    defaultValue: 0
    optional: true

  white:
    type: String
    optional: true
  black:
    type: String
    optional: true

@Players = new Mongo.Collection 'players'
@Players.attachSchema new SimpleSchema

  _gameId: type: String

  _userId: type: String

  createdAt: 
    type: Date
    autoValue: -> Tools.autoDefault new Date(), this
    optional: true

  nickname: 
    type: String
    max: 200

  item:
    type: String
    optional: true
  # player role
  # 0: common
  # 1: undercover
  role: type: Number

  # player status
  # 0: idle
  # 1: playing
  # 2: dead
  status: type: Number

  # number of votespoll count
  voteCount: type: Number

  # whether player is voted or not
  voted: type: Boolean

  ready:
    type: Boolean
    defaultValue: false
    optional: true

@alivePlayers = (gameId) ->
  Players.find
    _gameId: gameId
    status: 1

@awaitingPlayers = (gameId) ->
  Players.find
    _gameId: gameId
    status: 0

@deadPlayers = (gameId) ->
  Players.find
    _gameId: gameId
    status: 2

@Gamelogs = new Meteor.Collection 'gamelogs'
@Gamelogs.attachSchema new SimpleSchema
  _gameId: type: String
  createdAt: type: Date
  level: type: Number
  content: type: String

@gameLog = 
  clear: (gameId) ->
    Gamelogs.remove({_gameId: gameId})
  log: (gameId, level, content) ->
    Gamelogs.insert
      _gameId: gameId
      createdAt: Date.now()
      level: level
      content: content
  i: (gameId, content) ->
    @log gameId, 0, content
  p: (gameId, content) ->
    @log gameId, 1, content
  

@Lost = new Meteor.Collection 'lost'
@Lost.attachSchema new SimpleSchema
  _gameId: type: String
  _userId: type: String
  remaining: type: Number

@Items = new Meteor.Collection 'items'
@Items.attachSchema new SimpleSchema
  common:
    type: String
    label: "一般项目"
    max: 50
    autoform:
      placeholder: '一般项目'
    
  special: 
    type: String
    label: "卧底项目"
    max: 50
    autoform:
      placeholder: '卧底项目'
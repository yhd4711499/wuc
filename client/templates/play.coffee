gameId = ->
  Router.current().params._id
promote = undefined

clearup = (template) ->
  $('button.back-button, a.tab-item').off('click', promote)
  template.observe.stop()
  clearTimeout this.timer
  delete template.timer

Template.play.created = ->

  this.autorun(( ->
    Meteor.subscribe 'games', gameId()
    Meteor.subscribe 'gamelogs', gameId()
    Meteor.subscribe 'alivePlayers', gameId()
    Meteor.subscribe 'awaitingPlayers', gameId()
    Meteor.subscribe 'deadPlayers', gameId()
    Meteor.call 'joinGame', gameId(), (err, doc) ->
      if doc
        Session.set 'playing', true
  ).bind(this))
  self = this
  this.observe = Games.find( {_id: gameId()}, {fields: {status: 1, _ownerId: 1}} ).observe
    removed: (oldDocument) ->
      Session.set 'playing', false
      clearup self
      if oldDocument._ownerId == Meteor.userId()
        Router.go 'games'
        return
      IonPopup.show
        title: '房间已关闭'
        template: ''
        buttons: [{
          text: '退出',
          type: 'button-positive',
          onTap: -> 
            $('button.back-button, a.tab-item').off('click', promote)
            Router.go 'games'
            IonPopup.close();
        }]

      
    changed: (newDocument, oldDocument) ->
      if newDocument.status == 2
        Session.set 'showItem', true
        self.timer ?= setTimeout(
          (()-> Session.set 'showItem', false)
          , 3 * 1000)
  

Template.play.rendered = () ->
  self = this
  # $('body').hammer();
  promote = (e)->
    e.preventDefault()
    IonPopup.show
      title: '确定要退出游戏吗？'
      template: '真的确定要退出吗？'
      buttons: [{
        text: '退出',
        type: 'button-negative',
        onTap: -> 
          clearup self
          Meteor.call 'exitGame', gameId()
          Session.set 'playing', false
          $(e.target).trigger('click')
          IonPopup.close();
      },
      {
        text: '取消',
        type: 'button-positive',
        onTap: ->
          IonPopup.close();
      }]
        
    return false

  $('button.back-button, a.tab-item').on('click', promote)

Template.play.onDestroyed = () ->
  clearup this
# Template.play.rendered = ->
#   this.autorun(( ->
#     if not this.subscription.ready()
#       IonLoading.show()
#     else
#       IonLoading.hide()
    
#   ).bind(this))

Template.play.helpers
  game: -> Games.findOne _id: gameId()
  mAlivePlayers: -> alivePlayers(gameId())
  mAwaitingPlayers: -> awaitingPlayers(gameId())
  mDeadPlayers: -> deadPlayers(gameId())
  me: -> Players.findOne({_userId: Meteor.userId()})
  canVote: -> !Players.findOne({_userId: Meteor.userId()}).voted && (this._userId != Meteor.userId()) && (Games.findOne({_id: gameId()}).status == 2)
  gamelogs: -> Gamelogs.find({_gameId: gameId()}, {sort: {createdAt: -1}, limit: 5})
  banner: ->
    gamelog = Gamelogs.findOne({_gameId: gameId(), level: 1}, {sort: {createdAt: -1}})
    return gamelog ? Gamelogs.findOne({_gameId: gameId(), level: 0}, {sort: {createdAt: -1}})
  showItem: -> Session.get 'showItem'

Template.play.events
  'click [data-action="ready"]': () ->
    Meteor.call 'imReady'
  'click [data-action="notReady"]': () ->
    Meteor.call 'imNotReady'
  'click [data-action="vote"]': (event, template) ->
    Meteor.call 'vote', this._userId
  'touchstart [data-action="view"], mousedown [data-action="view"]': () ->
    Session.set 'showItem', true
    return false
  'touchend [data-action="view"], touchcancel [data-action="view"], mouseup [data-action="view"]': () ->
    Session.set 'showItem', false
    return false

      
    
    
    

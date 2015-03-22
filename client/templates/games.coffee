Template.games.created = ->
  $('a.tab-item').addClass('active')
  @autorun (->
    @subscription = Meteor.subscribe('games')
    return
  ).bind(this)
  return

Template.games.rendered = ->
  @autorun (->
    if !@subscription.ready()
      IonLoading.show()
    else
      IonLoading.hide()
    return
  ).bind(this)
  return

Template.games.helpers
  games: ->
    Games.find $or: [
      { status: 1 }
      { status: 2 }
    ]
  awaitingGames: ->
    Games.find status: 0

Template.games.events
  'click [data-action="new"]': () ->
    Router.go 'new'
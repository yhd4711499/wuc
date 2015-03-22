Template.items.rendered = ->
  @autorun (->
    if !@subscription.ready()
      IonLoading.show()
    else
      IonLoading.hide()
    return
  ).bind(this)

Template.items.created = ->
  @autorun(( ->
    @subscription = Meteor.subscribe 'items'
  ).bind(this))

Template.items.helpers
	items: -> Items.find()
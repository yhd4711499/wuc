AccountsTemplates.configure
	negativeValidation: false
	negativeFeedback: false
	positiveValidation: false
	positiveFeedback: false

Template.user.created = () ->
  @autorun(( ->
    @subscription = Meteor.subscribe 'games'
  ).bind(this))
	
Template.user.rendered = ->
  @autorun (->
    if !@subscription.ready()
      IonLoading.show()
    else
      IonLoading.hide()
    return
  ).bind(this)

Template.user.events 
	'click [data-action=logout]': ->
		AccountsTemplates.logout()
		return

Template.user.helpers
	rooms: -> Games.find({_ownerId: Meteor.userId()})
	current: -> Meteor.user()
	userJoinSchema: -> 
		new SimpleSchema
			profile: 
				label: '个人信息'
				type: Object
			'profile.nickname': 
				label: '昵称'
				type: String
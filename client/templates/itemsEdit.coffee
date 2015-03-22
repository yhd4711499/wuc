Template.itemsEdit.helpers
	item: -> Items.findOne _id: Template.instance().data.id

Template.itemsEdit.events
  'click [data-action="delete"]': () ->
    Items.remove({_id: Template.instance().data.id})

AutoForm.hooks 'items-edit-form':
  onSuccess: (operation, result, template) ->
    IonModal.close()
    return
  onError: (operation, error, template) ->
    return
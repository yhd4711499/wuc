AutoForm.hooks 'items-new-form':
  onSuccess: (operation, result, template) ->
    IonModal.close()
    # Router.go 'items'
    return
  onError: (operation, error, template) ->
    return
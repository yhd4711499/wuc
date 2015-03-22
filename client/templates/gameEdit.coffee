gameId = undefined

Template.gameEdit.helpers
	game: -> 
		gameId = Template.instance().data.id
		return Games.findOne _id: gameId

Template.gameEdit.events
	'click [data-action="delete"]': (e) ->
		e.preventDefault()
		IonPopup.show
			title: '确定要关闭该房间吗？'
			template: '房间内的玩家将会退出，并且该房间将会从服务器上删除'
			buttons: [{
				text: '确定',
				type: 'button-negative',
				onTap: -> 
					Games.remove({_id: gameId})
					IonPopup.close()
					IonModal.close()
			},
			{
				text: '取消',
				type: 'button-positive',
				onTap: ->
					IonPopup.close();
			}]
		

AutoForm.hooks 'games-edit-form':
	onSuccess: (operation, result, template) ->
		IonModal.close()
		return
	onError: (operation, error, template) ->
		return
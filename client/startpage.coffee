Template.app.approved = ->
	false

Template.app.yourSession = ->
	id = Meteor.userId()
	sessions.find({owner:id})

Template.app.events {
	'click #joinSession': (e,t)->
		

	'click #createSession': (e,t) ->
		title = document.getElementById('sessionTitle').value.trim()
		if title.length is 0
			document.getElementById('error').innerHTML = 'need title name'
		else 
			sessionId = makeId()
			userId = Meteor.userId()
			sessions.insert {
				title: title
				sessionId: sessionId
				owner: userId
			}
			document.getElementById('sessionTitle').value = ''

	'click .deleteSession': (e,t) ->
		sessions.remove this._id
		console.log this.sessionId
		# remove all questions in this session

}





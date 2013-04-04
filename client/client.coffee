upvotes = []

Meteor.startup ->
	cookies = document.cookie.split(';')
	# document.cookie.replace('upvotes=', '')
	for x in cookies
		names = x.split('=')
		value = names[0].trim()
		upvotes.push value

Session.set 'showing', 'popular'
Session.set 'questionEdit', null
Session.set 'showModal', 'hide'

Template.list.topics = ->
	tag_counts  = {}
	total_count = 0
	for question in comments.find({}).fetch()
		for tag in question.tags
			continue if tag is ''
			tag_counts[tag] = 0 unless tag_counts[tag]?
			tag_counts[tag] += question.votes
		total_count++
	tag_infos = for tag, count of tag_counts
		{ tag: tag, count: count }
	tag_infos = _.sortBy tag_infos, (x) -> x.count
	tag_infos.reverse()
	# tag_infos.unshift { tag: null, count: total_count }
	return tag_infos

Template.list.item = ->
	if not Session.equals 'tagfilter', null
		tagFilter = Session.get 'tagfilter'

	sel = {}
	sel.tags = tagFilter if tagFilter

	if Session.equals 'showing', 'recent'
		comments.find sel, {sort: {answered:1, time:-1}}
	else if Session.equals 'showing', 'popular'
		comments.find sel, {sort: {answered:1, votes:-1, time: -1}}
	else 
		comments.find sel, {sort: {time:-1}}

Template.list.recent = ->
	'toggle_selected' if Session.equals 'showing', 'recent'
		
Template.list.popular = ->
	'toggle_selected' if Session.equals 'showing', 'popular'
		
Template.list.ifchecked = ->
	if this._id in upvotes
		'checked'

Template.list.editing = ->
	Session.equals 'questionEdit', this._id

Template.list.moderator = ->
	if Meteor.user()?
		adminUser Meteor.userId()

Template.list.adminOnly = ->
	if Meteor.user()?
		Admin = Meteor.users.findOne({username:"admin"})
		Meteor.userId() is Admin._id

Template.list.answered = ->
	this.answered is true

Template.list.addingtag = ->
	Session.equals 'addingtag', this._id

Template.list.commentCount = ->
	this.comments.length

Template.list.events {
	'click #submitquestion': (e,t) ->
		Ask(e,t)

	'focusin #inputquestion': (e,t) ->
		if /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)
			$('html,body').animate({
			        scrollTop: $(document).height()
			   })
			$('#eraseMe').css('height','0px')
			$('#submitbox').css('position','relative')

	'focusout #inputquestion':(e,t) ->
		if /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)
			$('#eraseMe').css('height','49px')
			$('#submitbox').css('position','fixed')

	'keyup #inputquestion': (e,t) ->
		if e.which is 13
			Ask(e,t)

	'click .upvote': (e,t)->
		if this._id not in upvotes
			comments.update this._id, {$inc: {votes: 1 }}
			upvote(this._id)
		else 
			comments.update this._id, {$inc: {votes: -1}}
			downvote(this._id)

	'click #showPopular': (e,t) ->
		Session.set 'showing', 'popular'

	'click #showRecent': (e,t) ->
		Session.set 'showing', 'recent'

	'click .default': (e,t) ->
		Session.set 'tagfilter', null

	'click .menutag': (e,t) ->
		Session.set 'tagfilter', this.tag

	'dblclick .questionText': (e,t) ->
		if Meteor.user()? and adminUser Meteor.userId()
			Session.set 'questionEdit', this._id
			Deps.flush()
			focusText t.find('#questionEdit')

	'keyup #questionEdit': (e,t) ->
		if e.which is 13
			newquestion = e.target.value
			comments.update this._id, {$set: {question: newquestion}}
			Session.set 'questionEdit', null

	'focusout #questionEdit': (e,t) ->
		Session.set 'questionEdit', null

	'click .answered':(e,t) ->
		if this.answered is false
			comments.update this._id, {$set: {answered: true}} 
		else
			comments.update this._id, {$set: {answered: false}}

	'click .addtag':(e,t) ->
		Session.set 'addingtag', this._id
		Deps.flush()
		focusText t.find('#addtag')

	'keyup #addtag': (e,t) ->
		if e.which is 13
			console.log this._id
			newtags = e.target.value.split(',')
			comments.update this._id, {$set: {tags: newtags}}
			Session.set 'addingtag', null

	'focusout #addtag': (e,t) ->
		Session.set 'addingtag', null

	'click .delete': (e,t) ->
		console.log 'delete'
		comments.remove this._id

	'click #export': (e,t) ->
		JSON2CSV()
		
	'dblclick #clear': (e,t)->
		removeAll() 

	'click .showComments': (e,t) ->
		Session.set 'showModal', 'show'
		Session.set 'commentID', this._id
}


Template.commentModal.HideModal = ->
	Session.get 'showModal'

Template.commentModal.Header = ->
	id = Session.get 'commentID'
	comments.findOne(id)

Template.commentModal.moderator = ->
	if Meteor.user()?
		adminUser Meteor.userId()

Template.commentModal.events {
	'click .hideComment': (e,t) ->
		Session.set 'showModal', 'hide'

	'click #addComment': (e,t) ->
		id = Session.get 'commentID'
		Comment(e,t,id)

	'keyup #inputcomment': (e,t) ->
		if e.which is 13
			id = Session.get 'commentID'
			Comment(e,t,id)

	'click .deletecomment': (e,t) ->
		cmt = this.toString()
		id = Session.get 'commentID'
		comments.update id, {$pull: {comments: cmt}}
}

Template.list.preserve {
	'input.add'
}


Accounts.config({
	forbidClientAccountCreation: true;
});

Accounts.ui.config({
     passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'
});

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

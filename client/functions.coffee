JSON2CSV = () ->
    json = comments.find {}, {sort: {votes: -1}}
    str = 'Votes, Question \r\n'
    line = ''
    json.forEach (Item) ->
        # console.log Item.question + ',' + Item.votes + '\r\n'
        str += Item.votes + ',' + Item.question + '\r\n'
    # console.log str
    window.open("data:text/csv;charset=utf-8," + escape(str))

makeId = ->
    text = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    i = 0
    while i < 4
        text += possible.charAt(Math.floor(Math.random() * possible.length))
        i++
    text

removeAll = () ->
    all = comments.find {} 
    ids = []
    all.forEach (Item) ->
        ids.push Item._id
    for x in ids
        comments.remove {_id:x}

upvote = (id) ->
    upvotes.push id
    createCookie id,id,1
    # document.cookie =  upvotes.join(',') #+ ';expires="expires=Fri, 29 Mar 2013 20:47:11 UTC"'

downvote = (id) ->
    upvotes.remove id
    eraseCookie(id)
    # document.cookie = upvotes.join(',')

createCookie = (name, value, days) ->
  if days
    date = new Date()
    date.setTime date.getTime() + (days * 24 * 60 * 60 * 1000)
    expires = "; expires=" + date.toGMTString()
  else
    expires = ""
  document.cookie = name + "=" + value + expires + "; path=/"

eraseCookie = (name) ->
  createCookie name, "", -1

Ask = (e,t)->
    newquestion = document.getElementById('inputquestion').value.trim()
    if newquestion.length is 0
        console.log 'nothing to submit'
    else 
        comments.insert {
            question: newquestion
            time: Date.now()
            answered: false;
            tags: [];
            votes: 0
            comments: []
        }
        document.getElementById('inputquestion').value = ''

Comment = (e,t,id) ->
    # console.log id
    newcomment = document.getElementById('inputcomment').value.trim()
    if newcomment.length is 0
        console.log 'no Comment'
    else 
        comments.update {_id:id}, {$push:{comments: newcomment}}
        document.getElementById('inputcomment').value = ''

adminUser = (userId) ->
    moderate = Meteor.users.findOne({username: "moderator"})
    Admin = Meteor.users.findOne({username:"admin"})
    userId is Admin._id or userId is moderate._id

focusText = (i)->
    i.focus()
    i.select()

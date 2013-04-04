var comments = new Meteor.Collection('Comments')

Meteor.startup(function(){
    var admin = Meteor.users.findOne({username: "admin"});
    if ((admin === undefined) || (admin === 'undefined')) {
    	Accounts.createUser({
    	    username: "admin",
    	    password: "595commave"
    	})
    };
    var moderator = Meteor.users.findOne({username: "moderator"});
    if ((moderator === undefined) || (admin === 'undefined')) {
        Accounts.createUser({
            username: "moderator",
            password: "595commave"
        });
    }
    

});
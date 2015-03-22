Meteor.startup(function () {
  AutoForm.setDefaultTemplate('ionic');
});

Template.registerHelper('equals',
    function(v1, v2) {
        return (v1 === v2);
    }
);

Template.registerHelper('and',
    function() {
        return _.every(arguments, _.identity)
    }
);

Template.registerHelper("prettifyDate", function(timestamp) {
    return moment(timestamp).fromNow();
});

AccountsTemplates.addField({
  _id: "nickname",
  type: "text",
  required: true
});
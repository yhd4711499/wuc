// if (!(typeof MochaWeb === 'undefined')){
//     MochaWeb.testOnly(function(){
//         var selectGraceHopper = function(){
//             Session.set("selected_player", Meteor.users.findOne({_id: "ZYRcGt5L9vYCqWDDA"})._id);
//         };

//         var unselectPlayer = function(){
//             Session.set("selected_player", null);
//             Meteor.flush();
//         }

//         describe("Select yhd4711499@live.com", function(){
//             before(function(done){
//                 Meteor.autorun(function(){
//                     var grace = Meteor.users.findOne({_id: "ZYRcGt5L9vYCqWDDA"});
//                     if (grace){
//                         selectGraceHopper();
//                         done();
//                     }
//                 })
//             });

//             it("should show Grace the inside div class='name' (above the give points button)", function(){
//                 Meteor.flush();
//                 chai.assert.equal($("div.details > div.name").html(), "Grace Hopper");
//             });


//             it("should highlight Grace's name", function(){
//                 Meteor.flush();
//                 var parentDiv = $("span.name:contains(Grace Hopper)").parent();
//                 chai.assert(parentDiv.hasClass("selected"));
//             });
//         });

//         describe("Point Assignment", function(){
//             before(function(){
//                 selectGraceHopper();
//             });

//             it("should give a player 5 points when they are selected and the button is pressed", function(){
//                 var graceInitialPoints = Players.findOne({name: "Grace Hopper"}).score;
//                 $("input:button").click();
//                 chai.assert.equal(graceInitialPoints + 5, Players.findOne({name: "Grace Hopper"}).score);
//             });
//         });

//         describe("Player Ordering", function(){
//             it("should result in a list where the first player as many or more points than the second player", function(){
//                 var players = Template.leaderboard.players().fetch();
//                 chai.assert(players[0].score >= players[1].score);
//             });
//         })
//     });
// }/**
//  * Created by Ornithopter on 15/3/18.
//  */

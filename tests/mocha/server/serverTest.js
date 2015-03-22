/**
 * Created by Ornithopter on 15/3/18.
 */
if (!(typeof MochaWeb === 'undefined')) {
  MochaWeb.testOnly(function() {
    var user;
    user = void 0;
    describe('Server initialization', function() {
      before(function(done) {
        done();
      });
      it('should insert players into the database after server start', function() {
        chai.assert(Meteor.users.find().count() > 0);
      });
    });
    after(function() {});
  });
}

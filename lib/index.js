(function() {
  var crypto, hashPassword, mongoose, restify;

  restify = require('restify');

  mongoose = require('mongoose');

  crypto = require('crypto');

  hashPassword = function(password) {
    var sha256sum;
    sha256sum = crypto.createHash('sha256');
    sha256sum.update(password, 'utf-8');
    return sha256sum.digest('hex');
  };

  module.exports = function(server, db, options) {
    var Token, TokenSchema, User, UserSchema, defaultOpts, k, loginEndpoint, v;
    if (options == null) {
      options = {};
    }
    defaultOpts = {
      endpoint: '/user',
      fields: {},
      usernameMinLen: 1,
      usernameMaxLen: 100,
      passwordMinLen: 1,
      passwordMaxLen: 100,
      model: 'admin',
      username: 'admin',
      password: 'admin'
    };
    for (k in options) {
      v = options[k];
      defaultOpts[k] = v;
    }
    UserSchema = mongoose.Schema(require('./schema')(defaultOpts.fields));
    TokenSchema = mongoose.Schema(require('./tokenSchema')(defaultOpts.fields));
    User = db.model(defaultOpts.model, UserSchema);
    Token = db.model(defaultOpts.model + '.token', TokenSchema);
    loginEndpoint = defaultOpts.endpoint + '/login';
    require('./hooks')(server, User, Token, loginEndpoint);
    require('./route')(server, User, defaultOpts.endpoint);
    return User.count(function(err, count) {
      var user;
      if (count > 0) {
        return;
      }
      user = new User({
        username: defaultOpts.username,
        password: hashPassword(defaultOpts.password),
        createAt: Date.now()
      });
      return user.save(function(err, doc) {});
    });
  };

}).call(this);

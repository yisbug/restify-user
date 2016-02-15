(function() {
  var clients, crypto, generateToken, hashPassword, oauth2;

  oauth2 = require('restify-oauth2');

  crypto = require('crypto');

  clients = {
    androidClient: {
      secret: 'Neptune'
    },
    iosClient: {
      secret: 'Pluto'
    },
    httpClient: {
      secret: 'Mars'
    }
  };

  hashPassword = function(password) {
    var sha256sum;
    sha256sum = crypto.createHash('sha256');
    sha256sum.update(password, 'utf-8');
    return sha256sum.digest('hex');
  };

  generateToken = function(data) {
    var random, sha256, timestap;
    random = Math.floor(Math.random() * 100001);
    timestap = new Date().getTime();
    sha256 = crypto.createHmac('sha256', random + 'WOO' + timestap);
    return sha256.update(data).digest('base64');
  };

  module.exports = function(server, User, Token, endpoint) {
    return oauth2.ropc(server, {
      tokenEndpoint: endpoint,
      hooks: {
        validateClient: function(client, req, callback) {
          var valid;
          valid = (clients[client.clientId] !== void 0) && (clients[client.clientId].secret === client.clientSecret);
          return callback(null, valid);
        },
        grantUserToken: function(client, req, callback) {
          var password, tpassword, tusername, username;
          username = client.username;
          password = client.password;
          tusername = typeof username;
          tpassword = typeof password;
          !~['string', 'number'].indexOf(tusername) && callback(null, false);
          !~['string', 'number'].indexOf(tpassword) && callback(null, false);
          return User.findOne({
            username: username,
            password: hashPassword(password)
          }).exec(function(err, user) {
            var token, tokenStr;
            if (err || !user) {
              return callback(null, false);
            }
            tokenStr = generateToken(username + ':' + password);
            token = new Token({
              token: tokenStr,
              username: user.username,
              nickname: user.nickname,
              userid: user._id,
              createAt: new Date().getTime()
            });
            return token.save(function(err) {
              if (err) {
                return callback(err, false);
              }
              return callback(null, {
                token: tokenStr,
                username: user.username,
                nickname: user.nickname,
                userid: user._id
              });
            });
          });
        },
        authenticateToken: function(token, req, callback) {
          return Token.findOne({
            token: token
          }, function(err, doc) {
            if (err || !doc) {
              return callback(err, false);
            }
            req.user = doc;
            return callback(null, true);
          });
        }
      }
    });
  };

}).call(this);

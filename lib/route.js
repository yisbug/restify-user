(function() {
  var async, crypto, hashPassword, mongoose;

  crypto = require('crypto');

  async = require('async');

  mongoose = require('mongoose');

  hashPassword = function(password) {
    var sha256sum;
    sha256sum = crypto.createHash('sha256');
    sha256sum.update(password, 'utf-8');
    return sha256sum.digest('hex');
  };

  module.exports = function(server, User, endpoint) {
    server.post(endpoint + '', function(req, res, next) {
      var password, username;
      if (!req.user) {
        return res.send(401);
      }
      username = req.body.username;
      password = req.body.password;
      if (!username || !password) {
        return res.send(400, 'need username and password.');
      }
      return User.findOne({
        username: username
      }, function(err, doc) {
        var user;
        if (err) {
          return res.send(500, err);
        }
        if (doc) {
          return res.send(400, 'username already exists.');
        }
        req.body.password = hashPassword(req.body.password);
        req.body.createAt = Date.now();
        user = new User(req.body);
        return user.save(function(err, doc) {
          if (err) {
            return res.send(500, err);
          }
          return res.send(200, doc);
        });
      });
    });
    server.get(endpoint + '', function(req, res, next) {
      var limit, page;
      if (!req.user) {
        return res.send(401);
      }
      limit = req.params.limit || 0;
      page = parseInt(req.params.page) || 1;
      return async.parallel({
        count: function(cb) {
          return User.count(cb);
        },
        list: function(cb) {
          var query;
          query = User.find({});
          query = query.sort({
            createAt: 1
          });
          if (limit > 0) {
            query = query.limit(limit);
            query = query.skip((page - 1) * limit);
          }
          return query.exec(cb);
        }
      }, function(err, result) {
        if (err) {
          return res.send(500, err);
        }
        return res.send(200, result);
      });
    });
    server.get(endpoint + '/my', function(req, res, next) {
      if (!req.user) {
        return res.send(401);
      }
      return User.findOne({
        _id: mongoose.Types.ObjectId(req.user.userid)
      }, function(err, doc) {
        if (err) {
          return res.send(500, err);
        }
        return res.send(200, doc);
      });
    });
    server.get(endpoint + '/:userid', function(req, res, next) {
      var id, query, type;
      if (!req.user) {
        return res.send(401);
      }
      type = req.params.type || 'userid';
      id = req.params.userid;
      if (type === 'userid') {
        query = {
          _id: mongoose.Types.ObjectId(req.params.userid)
        };
      } else {
        query = {
          username: req.params.userid
        };
      }
      return User.findOne(query, function(err, doc) {
        if (err) {
          return res.send(500, err);
        }
        if (!doc) {
          return res.send(404);
        }
        return res.send(200, doc);
      });
    });
    server.put(endpoint + '/:userid', function(req, res, next) {
      if (!req.user) {
        return res.send(401);
      }
      return User.findOne({
        _id: mongoose.Types.ObjectId(req.params.userid)
      }, function(err, doc) {
        var k, ref, v;
        if (req.body.password) {
          req.body.password = hashPassword(req.body.password);
        }
        if (req.body.username && doc.username !== req.body.username) {
          return User.findOne({
            username: req.body.username
          }, function(err, otherUser) {
            var k, ref, v;
            if (err) {
              return res.send(500, err);
            }
            if (otherUser) {
              return res.send(400, 'new username already exists.');
            }
            ref = req.body;
            for (k in ref) {
              v = ref[k];
              doc[k] = v;
            }
            return doc.save(function(err, doc) {
              if (err) {
                return res.send(500, err);
              }
              return res.send(200, doc);
            });
          });
        } else {
          ref = req.body;
          for (k in ref) {
            v = ref[k];
            doc[k] = v;
          }
          return doc.save(function(err, doc) {
            if (err) {
              return res.send(500, err);
            }
            return res.send(200, doc);
          });
        }
      });
    });
    return server.del(endpoint + '/:userid', function(req, res, next) {
      if (!req.user) {
        return res.send(401);
      }
      return User.remove({
        _id: mongoose.Types.ObjectId(req.params.userid)
      }, function(err, rows) {
        if (err) {
          return res.send(500, err);
        }
        return res.send(200, rows);
      });
    });
  };

}).call(this);

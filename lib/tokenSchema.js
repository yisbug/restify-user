(function() {
  module.exports = function(fields) {
    var defaultSchema, k, v;
    defaultSchema = {
      token: String,
      username: String,
      nickname: String,
      createAt: Number,
      userid: String
    };
    for (k in fields) {
      v = fields[k];
      defaultSchema[k] = v;
    }
    return defaultSchema;
  };

}).call(this);

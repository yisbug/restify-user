(function() {
  module.exports = function(fields) {
    var defaultSchema, k, v;
    defaultSchema = {
      username: {
        type: String,
        required: true,
        index: {
          unique: true,
          dropDups: true
        }
      },
      password: {
        type: String,
        required: true
      },
      nickname: String,
      createAt: Number
    };
    for (k in fields) {
      v = fields[k];
      defaultSchema[k] = v;
    }
    return defaultSchema;
  };

}).call(this);

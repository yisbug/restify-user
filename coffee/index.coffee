restify = require 'restify'
mongoose = require 'mongoose'
crypto = require 'crypto'
# 加密密码字符串
hashPassword = (password)->
    sha256sum = crypto.createHash 'sha256'
    sha256sum.update password,'utf-8'
    sha256sum.digest 'hex'
module.exports = (server,db,options={})->
    defaultOpts = 
        endpoint:'/user' # 路由
        fields:{} # 其他自定义字段
        usernameMinLen:1 
        usernameMaxLen:100
        passwordMinLen:1
        passwordMaxLen:100
        model:'admin' # collection名称
        username:'admin' # 初始默认用户名
        password:'admin' # 初始默认密码
    defaultOpts[k]=v for k,v of options

    # 定义collections
    UserSchema = mongoose.Schema require('./schema') defaultOpts.fields
    TokenSchema = mongoose.Schema require('./tokenSchema') defaultOpts.fields
    User = db.model defaultOpts.model,UserSchema
    Token = db.model defaultOpts.model+'.token',TokenSchema

    # oauth2
    loginEndpoint = defaultOpts.endpoint+'/login'
    require('./hooks') server,User,Token,loginEndpoint

    # route
    require('./route') server,User,defaultOpts.endpoint

    # 添加默认账户
    User.count (err,count)->
        return if count > 0
        user = new User 
            username:defaultOpts.username
            password:hashPassword defaultOpts.password
            createAt:Date.now()
        user.save (err,doc)->

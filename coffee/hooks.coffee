# oauth2

crypto = require 'crypto'
# 客户端secret
clients = 
    androidClient:
        secret:'Neptune'
    iosClient:
        secret:'Pluto'
    httpClient:
        secret:'Mars'
# 加密密码字符串
hashPassword = (password)->
    sha256sum = crypto.createHash 'sha256'
    sha256sum.update password,'utf-8'
    sha256sum.digest 'hex'
# 创建一个token
generateToken = (data)->
    random = Math.floor Math.random() * 100001
    timestap = new Date().getTime()
    sha256 = crypto.createHmac 'sha256',random + 'WOO' + timestap
    sha256.update(data).digest 'base64'

module.exports = (server,User,Token,endpoint)->
    require('restify-oauth2').ropc server,
        tokenEndpoint:endpoint
        hooks:
            # 验证客户端的方法
            validateClient:(client,req,callback)->
                valid = (clients[client.clientId] isnt undefined) and (clients[client.clientId].secret is client.clientSecret)
                callback null,valid
            # 生成token
            grantUserToken:(client,req,callback)->
                username = client.username
                password = client.password
                User.findOne
                    username:username
                    password:hashPassword password
                .exec (err,user)->
                    return callback null,false if err or not user
                    tokenStr = generateToken username+':'+password
                    token = new Token
                        token:tokenStr
                        username:user.username
                        nickname:user.nickname
                        userid:user._id
                        createAt:new Date().getTime()
                    token.save (err)->
                        return callback err,false if err
                        callback null,
                            token:tokenStr
                            username:user.username
                            nickname:user.nickname
                            userid:user._id
            # 验证token
            authenticateToken:(token,req,callback)->
                Token.findOne
                    token:token
                ,(err,doc)->
                    return callback err,false if err or not doc
                    req.user = doc
                    return callback null,true

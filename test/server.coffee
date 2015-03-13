restify = require 'restify'
mongoose = require 'mongoose'
assert = require 'assert'
should = require 'should'

port = 8002

describe '测试服务',->
    endpoint = '/admin'

    token_type = 'Bearer'
    base_token = 'Basic aW9zQ2xpZW50OlBsdXRv'
    client = restify.createJSONClient
        url:'http://localhost:'+port

    # 默认管理员账户
    adminUsername = 'admin'
    adminPassword = 'admin'
    adminUserid = ''

    # 新注册的账户
    username = 'test' + Math.random()
    password = 'test'
    userid = ''
    userToken = ''
    userToken_type = ''

    # 管理员token
    adminToken = ''
    adminToken_type = ''

    userAdmin = ->
        client.headers.authorization = adminToken_type + ' ' + adminToken
    userGuest = ->
        client.headers.authorization = ''
    userLogin = ->
        client.headers.authorization = base_token
    userUser = ->
        client.headers.authorization = userToken_type + ' ' + userToken

    userList = ''

    before (done)->
        done()
    after (done)->
        done()

    describe '默认账户测试',->
        it '未授权获取账户信息',(done)->
            userAdmin()
            client.get endpoint+'/'+adminUsername+'?type=username',(err,req,res,obj)->
                assert.ifError not err
                done()
        it '使用默认账户登录',(done)->
            client.headers.authorization = base_token
            client.post endpoint+'/login',
                username:adminUsername
                password:adminPassword
                grant_type:'password'
            ,(err,req,res,obj)->
                assert.ifError err
                adminToken = obj.access_token.token
                adminUserid = obj.access_token.userid
                adminToken_type = obj.token_type
                done()
        it '使用username获取账户信息',(done)->
            userAdmin()
            client.get endpoint+'/'+adminUsername+'?type=username',(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal adminUsername
                done()
        it '使用userid获取账户信息',(done)->
            userAdmin()
            client.get endpoint+'/'+adminUserid,(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal adminUsername
                done()
        it '获取当前登录用户信息',(done)->
            userAdmin()
            client.get endpoint+'/my',(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal adminUsername
                done()
    describe '添加用户测试',->
        it '没有token添加账户应该失败',(done)->
            userGuest()
            client.post endpoint+'',{},(err,req,res,obj)->
                assert.ifError not err
                done()
        it '使用token添加账户',(done)->
            userAdmin()
            client.post endpoint+'',{username:username,password:password},(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal username
                userid = obj._id
                done()
        it '获取添加的账户基本信息,by username',(done)->
            userAdmin()
            client.get endpoint+'/'+username+'?type=username',(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal username
                done()
        it '使用添加的账户登录',(done)->
            userLogin()
            client.post endpoint+'/login',
                username:username
                password:password
                grant_type:'password'
            ,(err,req,res,obj)->
                assert.ifError err
                userToken = obj.access_token.token
                userToken_type = obj.token_type
                done()
        it '获取添加的账户基本信息',(done)->
            userUser()
            client.get endpoint+'/'+username+'?type=username',(err,req,res,obj)->
                assert.ifError err
                obj.username.should.be.equal username
                done()

        it '获取账户列表',(done)->
            userAdmin()
            client.get endpoint+'',(err,req,res,obj)->
                assert.ifError err
                obj.list.length.should.be.above 0
                userList = obj.list
                done()
        it '修改账户密码并使用新密码登录',(done)->
            userUser()
            client.put endpoint+'/'+userid,{password:'123123'},(err,req,res,obj)->
                assert.ifError err
                userLogin()
                client.post endpoint+'/login',
                    username:username
                    password:'123123'
                    grant_type:'password'
                ,(err,req,res,obj)->
                    assert.ifError err
                    done()
        it '修改用户名为admin失败',(done)->
            userUser()
            client.put endpoint+'/'+userid,{username:'admin',password:'123123'},(err,req,res,obj)->
                assert.ifError not err
                done()
        it '修改用户名为其他成功',(done)->
            userUser()
            randUsername = 'user'+Math.random()
            client.put endpoint+'/'+userid,{username:randUsername,password:'123123'},(err,req,res,obj)->
                assert.ifError err
                userLogin()
                client.post endpoint+'/login',
                    username:randUsername
                    password:'123123'
                    grant_type:'password'
                ,(err,req,res,obj)->
                    assert.ifError err
                    done()
        it '删除账户',(done)->
            userUser()
            client.del endpoint+'/'+userid,(err,req,res,obj)->
                assert.ifError err
                done()
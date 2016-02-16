restify = require 'restify'
mongoose = require 'mongoose'
UserCenter = require '../coffee/index'


db = null
server = null

describe '测试启动服务',->
    after (done)->
        server.close()
        db.close()
        done()
    it '启动服务',(done)->
        server = restify.createServer {}
        server.use restify.authorizationParser()
        server.use restify.bodyParser mapParams:false
        server.use restify.queryParser()
        db = mongoose.createConnection 'mongodb://localhost/restify-user-test'
        port = 8002
        db.once 'open',->
            UserCenter server,db,{
                endpoint:'/user'
                model:'admin'
                # fields:
                #     address:String # 地址
                #     qq:Number # qq号
                #     mobile:Number # 手机
                route: # 自定义路由
                    post:false # 新建  POST /user
                    put:false # 修改   PUT /user/:id
                    del:false # 删除   DEL /user/:id
                    get:false # 列表   GET /user
                    info:false # 详情
                    login:false # 登陆
            }
            server.listen port,->
                console.log 'server start on test mode.'

                done()





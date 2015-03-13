restify = require 'restify'
mongoose = require 'mongoose'
UserCenter = require '../coffee/index'

server = restify.createServer {}
server.use restify.authorizationParser()
server.use restify.bodyParser mapParams:false
server.use restify.queryParser()

db = mongoose.createConnection 'mongodb://localhost/restify-user-test'
port = 8002

db.once 'open',->
    UserCenter server,db,{
        endpoint:'/admin'
        model:'account'
    }
    server.listen port,->
        console.log 'server start on test mode.'




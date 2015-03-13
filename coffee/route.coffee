crypto = require 'crypto'
async = require 'async'
mongoose = require 'mongoose'
# 加密密码字符串
hashPassword = (password)->
    sha256sum = crypto.createHash 'sha256'
    sha256sum.update password,'utf-8'
    sha256sum.digest 'hex'
module.exports = (server,User,endpoint)->
    # 创建用户
    server.post endpoint+'',(req,res,next)->
        return res.send 401 if not req.user # 需要权限
        username = req.body.username
        password = req.body.password
        return res.send 400,'need username and password.' if not username or not password
        User.findOne username:username,(err,doc)->
            return res.send 500,err if err
            return res.send 400,'username already exists.' if doc
            req.body.password = hashPassword req.body.password
            req.body.createAt = Date.now()
            user = new User req.body
            user.save (err,doc)->
                return res.send 500,err if err
                res.send 200,doc
    # 登陆，已在hooks中定义
    # server.post endpoint+'/login'
    
    # 获取用户列表
    server.get endpoint+'',(req,res,next)->
        return res.send 401 if not req.user # 需要权限
        limit = req.params.limit or 0
        page = parseInt(req.params.page) or 1
        async.parallel
            count:(cb)->
                User.count cb
            list:(cb)->
                query = User.find {}
                query = query.sort {createAt:1}
                if limit > 0
                    query = query.limit(limit) 
                    query = query.skip (page-1)*limit
                query.exec cb
        ,(err,result)->
            return res.send 500,err if err
            res.send 200,result

    # 返回当前已登陆用户信息
    server.get endpoint+'/my',(req,res,next)->
        return res.send 401 if not req.user # 需要权限
        User.findOne _id:mongoose.Types.ObjectId(req.user.userid)
        ,(err,doc)->
            return res.send 500,err if err
            res.send 200,doc

    # 获取用户详细信息，支持type参数：userid/username
    server.get endpoint+'/:userid',(req,res,next)->
        return res.send 401 if not req.user # 需要权限

        type = req.params.type or 'userid'
        id = req.params.userid
        if type is 'userid'
            query = _id:mongoose.Types.ObjectId(req.params.userid)
        else
            query = username:req.params.userid
        User.findOne query,(err,doc)->
            return res.send 500,err if err
            return res.send 404 if not doc
            res.send 200,doc

    # 修改用户
    server.put endpoint+'/:userid',(req,res,next)->
        return res.send 401 if not req.user # 需要权限
        User.findOne _id:mongoose.Types.ObjectId(req.params.userid)
        ,(err,doc)->
            # 密码加密
            req.body.password = hashPassword(req.body.password) if req.body.password
            # 是否修改了用户名
            if req.body.username and doc.username isnt req.body.username
                User.findOne username:req.body.username,(err,otherUser)->
                    return res.send 500,err if err
                    return res.send 400,'new username already exists.' if otherUser
                    doc[k]=v for k,v of req.body
                    doc.save (err,doc)->
                        return res.send 500,err if err
                        res.send 200,doc
            else
                doc[k]=v for k,v of req.body
                doc.save (err,doc)->
                    return res.send 500,err if err
                    res.send 200,doc

    # 删除用户
    server.del endpoint+'/:userid',(req,res,next)->
        return res.send 401 if not req.user # 需要权限
        User.remove _id:mongoose.Types.ObjectId(req.params.userid),(err,rows)->
            return res.send 500,err if err
            res.send 200,rows


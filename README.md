# restify-user

一个通用的用户模块，基于`restify`,`mongoose`。


### 安装
    npm install restify-user

### 使用

示例：
```coffeescript
restify = require 'restify'
mongoose = require 'mongoose'
userCenter = require 'restify-user'

db = mongoose.createConnection 'mongodb://localhost/test'
db.once 'open',->
    server = restify.createServer()
    userCenter server,db,options
```

`userCenter`接收3个参数，分别为：

* `server`： 即`restify`创建的`server`实例。
* `db`：`mongoose`数据库连接对象
* `options`：其他参数,`object`类型

`options`参数支持字段：

* `endpoint` 路由地址，默认为`/user`
* `fields` 用户表其他扩展字段。
* `usernameMinLen` 用户名最小长度，默认为1
* `usernameMaxLen` 用户名最大长度，默认不做限制
* `passwordMinLen` 密码最小长度，默认为1
* `passwordMaxLen` 密码最大长度，默认不做限制


之后会自动创建`/user`路由，支持`restify`的`post/get/del/put`等请求。其中`/user`可在`options`的`entpoint`属性中重新定义。

### 路由

#### `POST /user` 创建用户
参数：
* `username` 登陆用户名
* `nickname` 昵称
* `password` 密码
* 其他自定义字段，由`options`中`fields`字段配置。


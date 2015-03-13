# restify-user

一个通用的用户模块，基于`restify`,`mongoose`。

每次新建项目都要加用户模块，干脆把这一部分剥离出来，以后用起来方便。

### 等待添加的功能

* 用户名密码约束长度。
* 限制`del`,`put`接口的权限，以适应普通用户的场景。

### 安装
    npm install restify-user

### 使用

示例：
```coffeescript
restify = require 'restify'
mongoose = require 'mongoose'
userCenter = require 'restify-user'

server = restify.createServer {}
server.use restify.authorizationParser()
server.use restify.bodyParser mapParams:false
server.use restify.queryParser()

db = mongoose.createConnection 'mongodb://localhost/test'
db.once 'open',->
    userCenter server,db,options
    sever.listen 8080,->
        console.log '%s listening at %s',server.name,server.url
```

`userCenter`接收3个参数，分别为：

* `server`： 即`restify`创建的`server`实例。
* `db`：`mongoose`数据库连接对象
* `options`：其他参数,`object`类型

> 注：`server`需要使用`bodyParser`等中间件


`options`参数支持字段：

* `endpoint` 路由地址，默认为`/user`
* `fields` 用户表其他扩展字段，使用`mongoose`中`Schema`所支持的格式。
* `model` 用户`collection`名称，默认为`admin`

目前还没实现的参数：

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

返回：

* `200` 创建成功，返回创建的用户数据。
* 其他失败

#### `GET /user` 获取用户列表

参数使用queryString

* `limit` 每页条数，默认不分页
* `page` 页码

返回`object`对象，属性：

* `count` 用户总数
* `list` 用户列表
* `page` 当前页码

#### `PUT /user/:userid` 修改用户基本信息

#### `DEL /user/:userid` 删除用户

#### `GET /user/:userid` 获取用户详细信息

参数使用queryString

* `type` 查询方式，支持`username`,`userid`，默认为`userid`。

#### `GET /user/my` 获取当前已登陆账户信息


#### `POST /user/login` 用户登陆

参数：

* `username`
* `password`
* `grant_type`  password

需要设置base token

如果成功则返回`200`,和`access_token`，其他状态为登陆失败。

* `access_token` object，包括：`token`,`username`,`userid`,`nickname`字段
* `token_type`


### 测试

> 所有测试均使用`coffeescript`编写。

#### 运行单个测试

    grunt test:[filename]

> 运行单个测试可以不加`test/`路径前缀和`.coffee`后缀。



module.exports = (fields)->
    defaultSchema = 
        token:String
        username:String
        nickname:String
        createAt:Number # 创建时间
        userid:String
    defaultSchema[k]=v for k,v of fields
    defaultSchema

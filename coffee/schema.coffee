module.exports = (fields)->
    defaultSchema = 
        username:
            type:String
            required:true
            index:
                unique:true
                dropDups:true
        password:
            type:String
            required:true
        nickname:String
        createAt:Number
    defaultSchema[k]=v for k,v of fields
    defaultSchema
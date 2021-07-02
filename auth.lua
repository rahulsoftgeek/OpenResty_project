local cjson = require "cjson.safe" 
local cjson = require "cjson"
local jwt = require "resty.jwt"
local db_conn = require "db" 

local function badAuth() 
    ngx.status = 401 
    ngx.say(cjson.encode({status="error",
             errmessage="Authentication Failed"})) 
    ngx.exit(401) 
end 
 
local function isAuthorised (key) 
    quoted_key = ngx.quote_sql_str(key)
    get_token = "select username from employees where token =" ..quoted_key
    db_token = db_conn.connect(db):query(get_token)
    json_token = cjson.encode(db_token)
    if json_token ~= '{}' then
        return true
    end
    return false 
end 
 
local authKey = ngx.req.get_headers()["X-API-KEY"] 
if authKey == nil then 
    badAuth() 
elseif not isAuthorised(authKey) then 
    badAuth() 
end 
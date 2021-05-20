
local redis = require("resty.redis")               
local mysql = require("resty.mysql")

local _M={}

local red = redis:new()
red:set_timeout(2000)
local ok, err = red:connect("127.0.0.1", 6379)

if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

_M.red = red

local db_conn, err = mysql:new()
if not db_conn then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
        
db_conn:set_timeout(10000) -- 10 sec
        
ok, err, errcode, sqlstate = db_conn:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "employee",
        user = "root",
        password = "password",
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }
        
if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

_M.db_conn = db_conn

return _M
        
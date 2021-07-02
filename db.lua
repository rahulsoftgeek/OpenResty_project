--local mysql = require "resty.mysql"

local _M={}

function _M.connect()

    local db, err = mysql:new()     -- new object for sql connection
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec   

    local ok, err, errcode, sqlstate = db:connect{
        host = os.getenv("host"),
        port = 3306,
        database = os.getenv("database"),
        user = os.getenv("user"),
        password = os.getenv("password"),
        charset = "utf8",
        max_packet_size = 1024 * 1024,
        pool = "mysql_conn_pool",
        pool_size =100,
    }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    return db
end

return _M
        
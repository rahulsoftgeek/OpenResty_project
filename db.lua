local mysql = require "resty.mysql"

local _M={}

function _M.connect()

    db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec

    local ok, err, errcode, sqlstate = db:connect{
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

    ngx.say("connected to mysql.")
    return db
end

function _M.redconnect()

    redis = require("resty.redis")                    -- Introduce Redis 
    red = redis:new()
    red:set_timeout(2000)
    local ok, err = red:connect("127.0.0.1", 6379)

    if not ok then
            ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end
    return red

end

return _M
        
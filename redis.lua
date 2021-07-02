local redis = require "resty.redis"                  -- Introduce Redis 

local _M={}

function _M.redconnect()

    local red_con = {pool = "red_conn_pool", pool_size = 100}

    local red = redis:new()
    red:set_timeout(2000)
    local ok, err = red:connect("127.0.0.1", 6379, red_con)

    if not ok then
            ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    local res, err = red:auth("password")
    if not res then
        ngx.say("failed to authenticate: ", err)
        return
    end

    return red

end

return _M
        
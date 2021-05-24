local _M={}

function _M.redconnect()

    redis = require("resty.redis")                    -- Introduce Redis 
    red = redis:new()
    red:set_timeout(2000)
    local ok, err = red:connect("172.31.29.85", 6379)

    if not ok then
            ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    return red

end

return _M
        
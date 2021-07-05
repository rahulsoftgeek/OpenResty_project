-- function reference
-- include
local mysql = require("resty.mysql")

local db = {}

function db.connect()
    local inst, err = mysql:new()
    if not inst then
        ngx.log(ngx.WARN, "failed to instantiate mysql: ", err)
        return
    end

    inst:set_timeout(3000)

    local ok, err, errcode, sqlstate = inst:connect{
        host = os.getenv("TESTDBHOST"), -- env var TESTDBHOST was in my .bash_profile
        port = 3306,
        database = "exampleDB",
        user = "root",
        password = "12345690",
        charset = "utf8mb4",
        max_packet_size = 1024 * 1024,
        pool = "mysql_conn_pool",
        pool_size =100,
    }

    if not ok then
        ngx.log(ngx.WARN, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    return inst
end

function db.keepalive(inst)
    local ok, err = inst:set_keepalive(60 * 1000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    end
end

return db
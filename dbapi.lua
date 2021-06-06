local mysql = require("resty.mysql")                   -- Introduce mysql
local db, err = mysql:new() 
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "employee",
    user = "root",
    password = "password",
    charset = "utf8",
    max_packet_size = 1024 * 1024,
    }

local cjson = require("cjson")                          -- Introduce cjson
local redis = require("resty.redis")                    -- Introduce Redis 
local red = redis:new()
red:set_timeout(2000)
local ok, err = red:connect("127.0.0.1", 6379)

if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end


ngx.req.read_body();                                     -- Required for ngx.req.get_body_data()
local reqPath = ngx.var.uri:gsub("api/", "")             -- Strip the api/ bit from the request path
local reqMethod = ngx.var.request_method                 -- Get the request method
local body = ngx.req.get_body_data() == nil and {} or cjson.decode(ngx.req.get_body_data()); -- Parse the body data as JSON

Api = {}
function Api.endpoint(method, path, callback)            -- Function for checking input from client
        if reqPath ~= path                               -- return false if path doesn't match anything
        then
            ngx.say("Bad Request")
            return false;
        end

        local body_param = cjson.decode(ngx.req.get_body_data())  
        local value = ""                                  -- get the value from body
            for k,v in pairs(body_param) do
                if k == "name" then
                    value = v
                end
            end

        local quoted_name = ngx.quote_sql_str(value)       -- to quote values
        local post_query = "insert into employees (name)" .. "values (" .. quoted_name ..")" 
        res, err, errcode, sqlstate = db:query(post_query) -- Posting data to db
        if not res then
            ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            return
        end
        ngx.say(res.affected_rows, " rows inserted into table employees ",
                                   "(last insert id: ", res.insert_id, ")") -- return id of added row
end

if reqMethod == 'POST' then                                                 -- verify if request is POST
    Api.endpoint('POST', '/test',
        function(body)
        end
    )
end

if reqMethod == 'GET' then                                                  -- verify if request is GET
    local id = tonumber(ngx.unescape_uri(ngx.var.arg_id))                   -- parsing URI & getting id
    local rescontent=red:get("id_"..id)                                     -- getting the value if record exist in redis
    local res_str = tostring(rescontent)
    
    if res_str == "userdata: NULL"  then                                    -- check if retured data is NULL
        local quoted_name_get = ngx.quote_sql_str(id)                       -- fetch data from db
        local get_query =  "select * from employees where id =" ..quoted_name_get
        res = db:query(get_query)
        get_res, err, errcode, sqlstate =
                db:query(get_query)
            if not get_res then
                ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                return
            end
        
        red:set("id_"..id,cjson.encode(res))                                  -- What to deposit to redis
        red:close()
        ngx.say("result: ", cjson.encode(res))                                -- return the result
        ngx.say("{flag:true}") 
    else
        ngx.say(rescontent)                                                   -- return data from redis
    end
end

if reqMethod ~= 'POST' and reqMethod ~= 'GET' then                            -- return error if any other request except GET and POST
    return ngx.say(
        cjson.encode({
            error=500,
                message="Method " .. reqMethod .. " not allowed"
            })
        )
end
        
local ok, err = db:set_keepalive(10000, 10000)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
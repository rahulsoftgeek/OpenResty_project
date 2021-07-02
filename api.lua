--local db_conn = require "db"                            --import the custom db module        
--local red_conn = require "redis"                        --import the custom redis module
--local cjson = require("cjson")                          -- Introduce cjson
ngx.req.read_body();                                     -- Required for ngx.req.get_body_data()
local reqPath = ngx.var.uri:gsub("api/", "")             -- Strip the api/ bit from the request path
local reqMethod = ngx.var.request_method                 -- Get the request method
local body = ngx.req.get_body_data() == nil and {} or cjson.decode(ngx.req.get_body_data()); -- Parse the body data as JSON

Api = {}
function Api.endpoint(method, path, callback)            -- Function for checking input from client
        if reqPath ~= path                               -- return false if path doesn't match anything
        then
            ngx.status = 400
            ngx.say("Bad Request")
            return false;
        end

        local body_param = cjson.decode(ngx.req.get_body_data())  
        local value = ""                                                    -- get the value from body
            for k,v in pairs(body_param) do
                if k == "name" then
                    value = v
                end
            end

        local quoted_name = ngx.quote_sql_str(value)                        -- to quote values
        local post_query = "insert into employees (name)" .. "values (" .. quoted_name ..")" 
        res, err, errcode, sqlstate = db_conn.connect(db):query(post_query) -- Posting data to db
        if not res then
            ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            return
        end
        ngx.say(res.affected_rows, " row inserted into table employees ",
                                   "(last insert id: ", res.insert_id, ")") -- return id of added row
end

if reqMethod == 'POST' then                                                 -- verify if request is POST
    Api.endpoint('POST', '/emp',
        function(body)
        end
    )
end

if reqMethod == 'PUT' then
    if reqPath ~= '/emp'                               -- return false if path doesn't match anything
        then
            ngx.status = 400
            ngx.say("Bad Request")
            return false;
        end
    local id = tonumber(ngx.var.arg_id)
    local quoted_put_id = ngx.quote_sql_str(id) 
    local body_param = cjson.decode(ngx.req.get_body_data())  
    local put_value = ""                                                 
        for k,v in pairs(body_param) do
            if k == "name" then
                put_value = v
            end
        end
    local quoted_put_name = ngx.quote_sql_str(put_value)
    local put_query = "update employees set name =" .. quoted_put_name .. " where id =" ..quoted_put_id
    local put_res, err, errcode, sqlstate = db_conn.connect(db):query(put_query)
    local get_query =  "select name,id from employees where id =" ..quoted_put_id
    local res, err, errcode, sqlstate = db_conn.connect(db):query(get_query)
    red_conn.redconnect(red):set("id_"..id,cjson.encode(res))
    ngx.say(put_res.affected_rows," row updated into table employees ")
end

if reqMethod == 'DELETE' then
    local id = tonumber(ngx.var.arg_id)
    local quoted_del_id = ngx.quote_sql_str(id) 
    local del_query =  "delete from employees where id =" ..quoted_del_id
    local del_res, err, errcode, sqlstate = db_conn.connect(db):query(del_query)
    local delcontent=red_conn.redconnect(red):del("id_"..id)
    ngx.say(del_res.affected_rows," row has been deleted from employees table")
end


if reqMethod == 'GET' then                                                  -- verify if request is GET
    if reqPath ~= '/emp'                               -- return false if path doesn't match anything
        then
            ngx.status = 400
            ngx.say("Bad Request")
            return false;
        end
    local id = tonumber(ngx.unescape_uri(ngx.var.arg_id))                   -- parsing URI & getting id
    local rescontent=red_conn.redconnect(red):get("id_"..id)                -- getting the value if record exist in redis
    local res_str = tostring(rescontent)
    
    if res_str == "userdata: NULL"  then                                    -- check if retured data is NULL
        local quoted_name_get = ngx.quote_sql_str(id)                       -- fetch data from db
        local get_query =  "select id,name from employees where id =" ..quoted_name_get
        local res, err, errcode, sqlstate =
        db_conn.connect(db):query(get_query)
            if not res or cjson.encode(res) == '{}' then
                ngx.status = 400
                ngx.say("Bad Request: ", err, ": ", errcode, ": ", sqlstate, ".")
                ngx.exit(400)
            end
        
        red_conn.redconnect(red):set("id_"..id,cjson.encode(res))                    -- What to deposit to redis
        ngx.say("Result from db: ", cjson.encode(res))                                -- return the result
    else
        ngx.say("Result from redis: ")
        ngx.say(rescontent)                                                   -- return data from redis
    end
end

if reqMethod ~= 'POST' and reqMethod ~= 'GET' and reqMethod ~= 'PUT' and reqMethod ~= 'DELETE' then                            -- return error if any other request except GET and POST
    ngx.status = 500
    ngx.say(
        cjson.encode({
            error=500,
                message="Method " .. reqMethod .. " not allowed"
            })
        )
    ngx.exit(500)

end

local ok, err = red_conn.redconnect(red):set_keepalive(1000, 100)  -- keep the connection in the connection pool
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

local ok, err = db_conn.connect(db):set_keepalive(1000, 100)       -- keep the connection in the connection pool
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
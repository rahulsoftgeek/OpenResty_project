-- function reference
local pcall = pcall
local type = type
local concat = table.concat
local sfind = string.find
-- include
local utils = require("utils")
local db = require("db")


local function getReq()
    local body = {}
    local headers = ngx.req.get_headers()

    local contentType = headers['Content-Type']
    if type(contentType) == "table" then contentType = concat(ct, ";") end
    if contentType then
        if sfind(contentType, "application/x-www-form-urlencoded", 1, true) then
            ngx.req.read_body()
            body = ngx.req.get_post_args()
        elseif sfind(contentType, "application/json", 1, true) then
            ngx.req.read_body()
            local json_str = ngx.req.get_body_data()
            body = utils.json_decode(json_str)
        -- elseif sfind(contentType, "multipart", 1, true) then -- todo:form-data request
        else    -- parsed as raw by default
            ngx.req.read_body()
            body = ngx.req.get_body_data()
        end
    else    -- the post request have no Content-Type header set will be parsed as x-www-form-urlencoded by default
        ngx.req.read_body()
        body = ngx.req.get_post_args()
    end

    local instance = {
        uri = ngx.var.request_uri,
        method = ngx.req.get_method(),
        headers = headers,
        query = ngx.req.get_uri_args(),
        body = body,
        rawBody = ngx.req.get_body_data(),
    }

    return instance
end

-- runtime
-- db example
local dbConn = db.connect()
if dbConn then
    local req = getReq()
    -- note: we often do SQL statements between `connect` and `keepalive` in a request from client
    -- for example:
    -- request is: curl -H "Content-Type:application/json" -X POST -d '{"username":"tweyseo3", "password":"123"}' "http://127.0.0.1:9527"
    --[[
        desc employee:
        +----------+--------------+------+-----+---------+----------------+
        | Field    | Type         | Null | Key | Default | Extra          |
        +----------+--------------+------+-----+---------+----------------+
        | id       | int unsigned | NO   | PRI | NULL    | auto_increment |
        | username | varchar(64)  | NO   |     | NULL    |                |
        | password | varchar(64)  | NO   |     | NULL    |                |
        | token    | varchar(128) | YES  |     | NULL    |                |
        +----------+--------------+------+-----+---------+----------------+
    ]] 
    local _username = ngx.quote_sql_str(req.body.username)
    local _password = ngx.quote_sql_str(req.body.password)
    local queryTokenSQL = "select token from employee where username=".._username.." and password=".._password
    local res, err, errcode, sqlstate = dbConn:query(queryTokenSQL) -- do SQL statements
    if not res then
        -- you are always recommend to use ngx.log to record log
        ngx.log(ngx.WARN, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        ngx.status(ngx.HTTP_INTERNAL_SERVER_ERROR)
        return ngx.say("internal server error!")
    end
    if utils.is_table_empty(res) then
        return ngx.say("empty result!")
    end
    local token = res[1].token
    if token == ngx.null then
        local token = ngx.var.request_id
        local updateTokenSQL = "update employee SET token="..ngx.quote_sql_str(token)
            .."where username=".._username.." and password=".._password
        res, err, errcode, sqlstate = dbConn:query(updateTokenSQL)  -- do SQL statements
        if not res then
            ngx.log(ngx.WARN, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            ngx.status(ngx.HTTP_INTERNAL_SERVER_ERROR)
            return ngx.say("internal server error!")
        end

        ngx.say("token is: ", token)
    end

    db.keepalive(dbConn)
else
    ngx.status(ngx.HTTP_INTERNAL_SERVER_ERROR)
    ngx.say("internal server error!")
end
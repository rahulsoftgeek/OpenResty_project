local userKey = ngx.req.get_headers()["username"] 
local passKey = ngx.req.get_headers()["password"] 

quoted_name = ngx.quote_sql_str(userKey)

get_username = "select username from employees where username =" ..quoted_name

db_username = db_conn.connect(db):query(get_username)

json_username = cjson.encode(db_username)

if json_username ~= '{}' then
    ngx.log(ngx.WARN,"username",json_username)
        get_password = "select pass from employees where username =" ..quoted_name

        db_password = db_conn.connect(db):query(get_password)

        if password == db_password then
            ngx.log(ngx.WARN,"password",db_password)
                local jwt_token = jwt:sign("lua-resty-jwt",
                                    {
                                    header={typ="JWT", alg="HS256"},
                                    payload={name=quoted_name}
                                    }
                                );
                ngx.say(cjson.encode(jwt_token));
                quoted_token = ngx.quote_sql_str(jwt_token)
                get_token = "update employees set token =" .. quoted_token .. " where username ="..quoted_name
                db_token = db_conn.connect(db):query(get_token)
                ngx.log(ngx.WARN,"db_token",db_token)
                end
else
    ngx.status = 401 
    ngx.say(cjson.encode({status="error",
             errmessage="Authentication Failed"})) 
    ngx.exit(401) 
end 
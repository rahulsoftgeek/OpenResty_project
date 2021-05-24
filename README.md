# OpenResty_project

Openresty API Example

POST request : curl --location --request POST 'api.gargrahul.com/api/test' \ 
-H 'Content-Type: application/json' -H 'X-API-KEY: abc123' \
--data-raw '{
        "name" : "peter"    
}'

GET request : curl --location -H 'X-API-KEY: abc123' --request GET 'api.gargrahul.com/api/test?id=7'


# OpenResty REST APIs

[![lua](https://img.shields.io/badge/lua-5.1-brightgreen)](http://www.lua.org/start.html#installing)
[![openresty](https://img.shields.io/badge//openresty-1.19.3.1-red)](https://openresty.org/en/download.html)


- OpenResty allows Lua based scripting to create web applications directly on the Nginx webserver.
- This code is running inside the Nginx worker process and therefore does not need to be interpreted or compiled by another service; making it an efficient solution.
- This is just a simple example of how we can expose an API endpoint using Nginx (nginx.conf) which passes the request to a Lua script (api.lua). 
- Deployed this application on AWS using multiple services like EC2, NAT instance, Application Load balancer, Route53, ACM, VPC, Security Group.
- openresty is running inside a docker container and uploaded all the docker images on dockerhub.
- Also, for Authentication purpose, added auth.lua in nginx.conf to authticate user.
- Here, on the backend we are running mysql database and redis for cache.
- Exposing API endpoints to POST (post employee name), GET (retreive employee info) and PUT (update employee info) request methods.

### Prerequisites

* GIT
* [MySQL](https://hub.docker.com/_/mysql)
* [redis](https://hub.docker.com/_/redis)
* [Docker](https://www.docker.com/products/docker-desktop)

### Build Image

```bash
git clone https://github.com/rahulsoftgeek/OpenResty_project.git
cd OpenResty_project/
docker build -t gargrahulcs/openresty:tag .
```

### Run Image

-- All the docker images related to this project are stored in a public repository on Docker hub. (gargrahulcs/openresty) 

-- Do change credentials of Mysql and Redis in the db.lua and redis.lua according to your database & redis cluster & connect with them.

-- Also, for Authentication set the paramter of API keys in the auth.lua and accordinly, send the API keys using `"X-API-KEY"` in the request header.

```bash
docker run -d \
    --name=openresty \
    -p 8082:8082 \
    gargrahulcs/openresty:tag
```
If everything works fine then you should able to send requests at `localhost:8082\api\emp`.

### API Information

I have received basic information of response status code, response header while sending below request.
```bash
$curl -I https://apis.gargrahul.com               
>HTTP/2 200 
>content-type: text/html
>server: openresty/1.19.3.1
```

1 - Adding new Employee name in the database using `POST` Request (Also, added content type and API keys in the request header)

```bash
POST request : curl -i --request POST 'apis.gargrahul.com/api/emp' \ 
-H 'Content-Type: application/json' -H 'X-API-KEY: abc123' \
--data-raw '{ "name" : "peter" }'

>HTTP/2 200
>content-type: application/json
>server: Rahul-server
>1 rows inserted into table employees (last insert id: 5)
```

2 - Received Employee Record from the database using `GET` Request.Also, implemented redis cache in the middle of application and database.
    So, if we hit the same request again it would send back the result from redis cache.
 
 -- Result from `DB`
 
 ```bash
GET request : curl -i -H 'X-API-KEY: abc123' --request GET 'https://apis.gargrahul.com/api/emp?id=5'

>HTTP/2 200 
>content-type: application/json
>server: Rahul-server
>Result from db: [{"name":"peter","id":5}]
 ```
 
 -- Result from `Redis` after sending the same GET request
 
 ```bash
 curl -i -H 'X-API-KEY: abc123' --request GET 'https://apis.gargrahul.com/api/emp?id=5'

>HTTP/2 200 
>content-type: application/json
>server: Rahul-server
>Result from redis: [{"name":"peter","id":5}]
 ```
 
3 - Updating Employee name using `PUT` Request.

 ```bash
PUT request : curl -i --request PUT 'https://apis.gargrahul.com/api/emp?id=7' \ 
-H 'Content-Type: application/json' -H 'X-API-KEY: abc123' \
--data-raw '{
        "name" : "joy"    
}'

>HTTP/2 200 
>content-type: application/json
>server: Rahul-server
>1 row updated into table employees 
 ```
 
### AWS Architecture

I hosted the openresty application on AWS cloud and below is the architecture of the application.

![image](https://user-images.githubusercontent.com/18359745/120928982-1b0ab980-c6b5-11eb-9ca8-ac1afc18c6d4.png)

- Running the docker container of openresty server on EC2 instance inside custom VPC and public subnet.
- Also, running docker container of MySQL and redis on different EC2 instance inside the same VPC in private subnet and connect with NAT instance to access the internet.
- Configured the application load balancer to balance the web traffic. Also, provide fault-tolerance (Highly Available) & high performance.
- Added DNS endpoint of ALB to Route 53 to access an application.

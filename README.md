# OpenResty REST APIs

[![lua](https://img.shields.io/badge/lua-5.1-brightgreen)](http://www.lua.org/start.html#installing)
[![openresty](https://img.shields.io/badge//openresty-1.19.3.1-red)](https://openresty.org/en/download.html)


- OpenResty allows Lua based scripting to create web applications directly on the Nginx webserver.
- This code is running inside the Nginx worker process and therefore does not need to be interpreted or compiled by another service; making it an efficient solution.
- This is just a simple example of how we can expose an API endpoint using Nginx (nginx.conf) which passes the request to a Lua script (api.lua). 
- Deployed this application on AWS using multiple services like EC2, Application Load balancer, Route53, VPC, Security Group.
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

-- 
```bash
docker run -d \
    --name=openresty \
    -p 8082:8082 \
    gargrahulcs/openresty:tag
```
If everything works fine then you should able to see APIs at `localhost:8082\api\emp`.

### API Information

1 - Authentication
2 - Adding new Employee record
3 - Getting Employee record
4 - Updating Employee record

POST request : curl --location --request POST 'apis.gargrahul.com/api/emp' \ 
-H 'Content-Type: application/json' -H 'X-API-KEY: abc123' \
--data-raw '{
        "name" : "peter"    
}'

GET request : curl --location -H 'X-API-KEY: abc123' --request GET 'apis.gargrahul.com/api/emp?id=7'

PUT request : curl --location --request PUT 'apis.gargrahul.com/api/emp?id=7' \ 
-H 'Content-Type: application/json' -H 'X-API-KEY: abc123' \
--data-raw '{
        "name" : "joy"    
}'

### AWS Architecture

I hosted the openresty application on AWS cloud and below is the architecture of the application.

![image](https://user-images.githubusercontent.com/18359745/120928982-1b0ab980-c6b5-11eb-9ca8-ac1afc18c6d4.png)

- Running the docker container of openresty server on EC2 instance inside custom VPC and public subnet.
- Also, running docker container of MySQL and redis on different EC2 instance inside the same VPC in private subnet and connect with NAT instance to access the internet.
- Configured the application load balancer to balance the web traffic and high availability.
- Added DNS endpoint of ALB to Route 53 to host an application.

FROM openresty/openresty:latest

RUN rm /usr/local/openresty/nginx/conf/nginx.conf

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean

COPY . /usr/local/openresty/nginx/conf/

ENV host = "127.0.0.1"      
ENV port = 3306             
ENV database = "employee"   
ENV user = "root"           
ENV password = "password"   

CMD ["/usr/bin/openresty", "-g", "daemon off;"]


STOPSIGNAL SIGQUIT

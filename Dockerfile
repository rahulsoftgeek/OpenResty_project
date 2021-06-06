FROM openresty/openresty:latest

RUN mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx_old.conf

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean

COPY . /usr/local/openresty/nginx/conf/

CMD ["/usr/bin/openresty", "-g", "daemon off;"]






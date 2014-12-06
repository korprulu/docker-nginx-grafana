FROM ubuntu:14.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install curl nginx -y

ENV GRAFANA_VERSION 1.9.0
ADD grafana_site /etc/nginx/sites-enabled/grafana

# Remove default site
RUN if [ -f /etc/nginx/sites-enabled/default ]; then rm /etc/nginx/sites-enabled/default; fi

# Install grafana
RUN curl -s -o /tmp/grafana.tar.gz http://grafanarel.s3.amazonaws.com/grafana-${GRAFANA_VERSION}.tar.gz && \
    tar -zxf /tmp/grafana.tar.gz -C / && \
    mv /grafana-${GRAFANA_VERSION} /grafana && \
    rm /tmp/grafana.tar.gz

# Grafana config file
# ADD config.js /grafana/config.js
RUN ln -s /data/grafana_config.js /grafana/config.js

# Auth basic
ADD htpasswd /.htpasswd

RUN chmod -R 400 /.htpasswd && \
    chown -R www-data.www-data /.htpasswd /grafana

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ENTRYPOINT nginx

FROM terjesannum/sensu-base:1
LABEL maintainer "terje@offpiste.org"

ENV LOG_LEVEL=info

ENV INFLUXDB_DATABASE=metrics
ENV INFLUXDB_USER=sensu
ENV INFLUXDB_PASSWORD=sensu

ENV RABBITMQ_VHOST=/
ENV RABBITMQ_USER=guest
ENV RABBITMQ_PASSWORD=guest

ENV BUFFER_SIZE 1000
ENV PROXY_BUFFER_SIZE 10

VOLUME /var/log/sensu

RUN mkdir -p /etc/sensu/extensions
RUN curl https://raw.githubusercontent.com/jhrv/sensu-influxdb-extension/master/influxdb-extension.rb > /etc/sensu/extensions/influxdb-extension.rb
RUN curl https://raw.githubusercontent.com/jhrv/sensu-influxdb-proxy-extension/master/influxdb-proxy-extension.rb > /etc/sensu/extensions/influxdb-proxy-extension.rb
RUN cat /etc/sensu/extensions/influxdb-proxy-extension.rb | sed 's/influxdb-proxy-extension/influxdb-proxy-extension-nano/g' | sed 's/InfluxDBProxy/InfluxDBNanoProxy/g' > /etc/sensu/extensions/influxdb-proxy-extension-nano.rb

COPY sensu.json redis.json /etc/sensu/conf.d/

COPY run.sh /opt/
CMD ["/opt/run.sh"]

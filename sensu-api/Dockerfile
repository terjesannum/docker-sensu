FROM terjesannum/sensu-base:2
LABEL maintainer "terje@offpiste.org"

EXPOSE 4567

ENV LOG_LEVEL=info

ENV REDIS_URL=redis://redis:6379/0
ENV RABBITMQ_URL=amqp://rabbitmq:5672/%2F

COPY api.json /etc/sensu/conf.d/

COPY run.sh /opt/
CMD ["/opt/run.sh"]

#!/bin/sh

mkdir -p /etc/sensu/conf.d/

cat << EOF > /etc/sensu/conf.d/rabbitmq.json
{
  "rabbitmq": {
    "host": "$RABBITMQ_HOST",
    "port": $RABBITMQ_PORT,
    "vhost": "$RABBITMQ_VHOST",
    "user": "$RABBITMQ_USER",
    "password": "$RABBITMQ_PASSWORD"
  }
}
EOF

cat << EOF > /etc/sensu/conf.d/client.json
{
  "client": {
    "name": "sensu-client_$HOSTNAME",
    "address": "$HOSTNAME",
    "subscriptions": [],
    "tags": {
      "hostname": "$HOSTNAME"
    },
    "socket": {
      "bind": "0.0.0.0",
      "port": 3030
    }
  }
}
EOF

exec /opt/sensu/bin/sensu-client -d /etc/sensu/conf.d -L $LOG_LEVEL

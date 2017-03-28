#!/bin/sh

cat << EOF > /etc/sensu/conf.d/influxdb-extension.json
{
  "influxdb-extension": {
    "hostname": "influxdb",
    "port": 8086,
    "database": "$INFLUXDB_DATABASE",
    "username": "$INFLUXDB_USER",
    "password": "$INFLUXDB_PASSWORD",
    "buffer_size": $BUFFER_SIZE
  }
}
EOF

cat << EOF > /etc/sensu/conf.d/influxdb-proxy-extension.json
{
  "influxdb-proxy-extension": {
    "hostname": "influxdb",
    "port": 8086,
    "database": "$INFLUXDB_DATABASE",
    "username": "$INFLUXDB_USER",
    "password": "$INFLUXDB_PASSWORD",
    "buffer_size": $PROXY_BUFFER_SIZE,
    "proxy_mode": true,
    "precision": "s"
  }
}
EOF

cat << EOF > /etc/sensu/conf.d/influxdb-proxy-extension-nano.json
{
  "influxdb-proxy-extension-nano": {
    "hostname": "influxdb",
    "port": 8086,
    "database": "$INFLUXDB_DATABASE",
    "username": "$INFLUXDB_USER",
    "password": "$INFLUXDB_PASSWORD",
    "buffer_size": $PROXY_BUFFER_SIZE,
    "proxy_mode": true,
    "precision": "n"
  }
}
EOF

cat << EOF > /etc/sensu/conf.d/rabbitmq.json
{
  "rabbitmq": {
    "host": "rabbitmq",
    "port": 5672,
    "vhost": "$RABBITMQ_VHOST",
    "user": "$RABBITMQ_USER",
    "password": "$RABBITMQ_PASSWORD"
  }
}
EOF

/opt/sensu/bin/sensu-server -d /etc/sensu/conf.d -e /etc/sensu/extensions -l /var/log/sensu/server-$HOSTNAME.log -L $LOG_LEVEL

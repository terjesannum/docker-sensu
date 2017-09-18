#!/bin/sh

mkdir -p /etc/sensu/conf.d

cat << EOF > /etc/sensu/conf.d/sensu.json
{
  "api": {
    "host": "$SENSU_HOST",
    "port": $SENSU_PORT
  },
  "handlers": {
    "default": {
      "type": "pipe",
      "command": "cat"
    },
    "metrics": {
      "type": "set",
      "handlers": ["influxdb-extension"]
    },
    "events": {
      "type": "set",
      "handlers": ["influxdb-extension"]
    },
    "events_nano": {
      "type": "set",
      "handlers": ["influxdb-extension"]
    }
  },
  "extensions": {
    "influxdb": {
      "gem": "sensu-extensions-influxdb"
    }
  }
}
EOF

cat << EOF > /etc/sensu/conf.d/redis.json
{
  "redis": {
    "host": "$REDIS_HOST",
    "port": $REDIS_PORT
  }
}
EOF

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

cat << EOF > /etc/sensu/conf.d/influxdb-extension.json
{
  "influxdb-extension": {
    "hostname": "$INFLUXDB_HOST",
    "port": $INFLUXDB_PORT,
    "database": "$INFLUXDB_DATABASE",
    "username": "$INFLUXDB_USER",
    "password": "$INFLUXDB_PASSWORD",
    "buffer_size": $BUFFER_SIZE,
    "buffer_max_age": $BUFFER_MAX_AGE,
    "additional_handlers": ["events", "events_nano"]
  },
  "events": {
    "proxy_mode": true,
    "precision": "s"
  },
  "events_nano": {
    "proxy_mode": true,
    "precision": "n"
  }
}
EOF

exec /opt/sensu/bin/sensu-server -d /etc/sensu/conf.d -L $LOG_LEVEL

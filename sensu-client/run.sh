#!/bin/sh

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

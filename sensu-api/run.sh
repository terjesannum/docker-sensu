#!/bin/sh

exec /opt/sensu/bin/sensu-api -d /etc/sensu/conf.d -l /var/log/sensu/api.log -L $LOG_LEVEL

#!/bin/sh

exec /opt/sensu/bin/sensu-api -d /etc/sensu/conf.d -L $LOG_LEVEL

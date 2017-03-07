#!/bin/sh

DIR=`cd $(dirname $0); pwd -P`

docker run -d --rm --link rabbitmq -v $DIR/volumes/sensu/logs:/var/log/sensu terjesannum/sensu-client:1

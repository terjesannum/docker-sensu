#!/bin/sh

DIR=`cd $(dirname $0); pwd -P`

docker run -d --rm --link rabbitmq terjesannum/sensu-client:4

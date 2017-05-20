#!/bin/sh

DIR=`cd $(dirname $0); pwd -P`

echo Starting containers...
docker run -d --rm --name=influxdb -p 8086:8086 influxdb:1.2.2
docker run -d --rm --name=redis -p 6379:6379 redis:3.2.8
docker run -d --rm --name=rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.6.9-management
docker run -d --rm --name=sensu-api -p 4567:4567 --link redis --link rabbitmq -v $DIR/volumes/sensu/logs:/var/log/sensu terjesannum/sensu-api:2
docker run -d --rm --name=uchiwa -p 3000:3000 --link sensu-api -v $DIR/volumes/uchiwa/config:/config uchiwa/uchiwa:0.24.0-1
cat $DIR/metrics.influx | docker exec -i influxdb influx
docker run -d --rm --name=sensu-server --link sensu-api --link redis --link rabbitmq --link influxdb -v $DIR/volumes/sensu/logs:/var/log/sensu terjesannum/sensu-server:5
docker run -d --rm --name=sensu-client -p 3030:3030 --link rabbitmq -v $DIR/volumes/sensu/logs:/var/log/sensu terjesannum/sensu-client:3
docker run -d --rm --name=grafana -p 3001:3000 --link influxdb -v $DIR/volumes/grafana/lib:/var/lib/grafana grafana/grafana:4.2.0
echo Writing some initial data to influxdb...
if perl -c $DIR/write-metrics.pl 2>/dev/null; then
    $DIR/write-metrics.pl
    $DIR/write-metrics.pl --measurement random --tag hostname --series 1 --total 1000 --generator random --scale 100
    echo
    echo "Write metrics to the sensu socket with 'write-metrics.pl --output sensu [options]'"
else
    >&2 echo write-metrics.pl requires perl installed
fi

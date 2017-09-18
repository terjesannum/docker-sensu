#!/bin/sh

DIR=`cd $(dirname $0); pwd -P`

echo Starting containers...
docker run -d --rm --name=influxdb -p 8086:8086 influxdb:1.2.4
docker run -d --rm --name=redis -p 6379:6379 redis:3.2.9
docker run -d --rm --name=rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.6.9-management
docker run -d --rm --name=sensu-api -p 4567:4567 --link redis --link rabbitmq terjesannum/sensu-api:3
docker run -d --rm --name=uchiwa -p 3000:3000 --link sensu-api -v $DIR/volumes/uchiwa/config:/config uchiwa/uchiwa:0.25.2-1
cat $DIR/metrics.influx | docker exec -i influxdb influx
docker run -d --rm --name=sensu-server --link sensu-api --link redis --link rabbitmq --link influxdb terjesannum/sensu-server:6
docker run -d --rm --name=sensu-socket -p 3030:3030 --link rabbitmq terjesannum/sensu-socket:2
docker run -d --rm --link rabbitmq terjesannum/sensu-client:4
docker run -d --rm --link rabbitmq terjesannum/sensu-client:4
docker run -d --rm --name=grafana -p 3001:3000 --link influxdb -v $DIR/volumes/grafana/lib:/var/lib/grafana grafana/grafana:4.3.0
echo Writing some initial data to influxdb...
if perl -c $DIR/write-metrics.pl 2>/dev/null; then
    $DIR/write-metrics.pl
    $DIR/write-metrics.pl --measurement random --tag hostname --series 1 --total 1000 --generator random --scale 100
    echo
    echo "Play with 'write-metrics.pl --output sensu [options]' to write additional data to the sensu socket"
else
    echo write-metrics.pl requires perl installed 1>&2
fi

#!/usr/bin/perl

use LWP::UserAgent;
use Getopt::Long;
use POSIX qw(strftime);
use IO::Socket::INET;

$output = 'influx';
$influx_url = 'http://localhost:8086';
$influx_db = 'metrics';
$influx_user = 'sensu';
$influx_password = 'sensu';
$sensu_host = 'localhost';
$sensu_port = 3030;
$measurement = 'test.foo';
$tag = 'zot';
$series = 10;
$batch = 50;
$total = 10000;
$start_time = time - 60*60*24;
$end_time = time;

GetOptions("output=s", \$output,
           "influx_url=s", \$influx_url,
           "influx_db=s", \$influx_db,
           "influx_user=s", \$influx_user,
           "influx_password=s", \$influx_password,
           "sensu_host=s", \$sensu_host,
           "sensu_port=i", \$sensu_port,
           "measurement=s", \$measurement,
           "tag=s", \$tag,
           "series=i", \$series,
           "batch=i", \$batch,
           "total=i", \$total,
           "start_time=i", \$start_time,
           "end_time=i", \$end_time
    );

$ua = LWP::UserAgent->new;

$data = [];
for($i=0; $i<$total; $i++) {
    $t = $start_time + $i * (($end_time - $start_time) / ($total - 1));
    push(@$data, sprintf("%s,%s=%d value=%d %d", $measurement, $tag, $i % $series, ($i+$i%$series)%100, ($t*1000*1000*1000)+($i%1000)));
    if($i && !($i % $batch)) {
        write_data($data);
        $data = [];
    }
}
write_data($data) if(@$data > 0);

printf("Wrote %d entries in %d series from %s to %s\n", $total, $series, strftime("%Y-%m-%d %H:%M:%S", localtime($start_time)), strftime("%Y-%m-%d %H:%M:%S", localtime($end_time)));

sub write_data {
    my($data) = @_;
    if($output eq 'influx') {
        write_influx($data);
    } elsif($output eq 'sensu') {
        write_sensu($data);
    } else {
        die("Unknown output: $output\n");
    }
}

sub write_influx {
    my($data) = @_;
    my($req) = HTTP::Request->new(POST => "$influx_url/write?db=$influx_db&u=$influx_user&p=$influx_password");
    $req->content(join("\n", @$data));
    my($res) = $ua->request($req);
    warn("write error: %s\n", $res->code) if(!$res->is_success);
}

sub write_sensu {
    my($data) = @_;
    my $socket = new IO::Socket::INET(
        PeerHost => $sensu_host,
        PeerPort => $sensu_port,
        Proto => 'tcp',
        );
    warn "Couldn't connect to sensu socket.\n" unless($socket);
    my $msg = sprintf('{"name":"%s","type":"metric","handlers":["events_nano"],"output":"%s"}',$measurement, join("\\n", @$data));
    my $l = $socket->send($msg);
    if($l == length($msg)) {
        my $res = '';
        $socket->recv($res, 1024);
        warn("write error: %s\n", $res) if($res ne 'ok');
    } else {
        warn("Socket write error.\n");
    }
    $socket->close();
}

#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojo::RabbitMQ::Client;

my $url = 'amqps://USER:PASS@rabbit.suse.de:5671?exchange=pubsub';
my $publisher = Mojo::RabbitMQ::Client->publisher(url => $url);
$publisher->publish_p({name => 'test', status => 'ok'},
  routing_key => 'suse.bot.status')->then(sub { say 'Status updated' })
  ->catch(sub { say "Updating status failed: $_[1]" })->wait;

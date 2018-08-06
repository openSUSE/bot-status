#
# Copyright (c) 2018 SUSE LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
package SUSE::BotStatus::Command::watcher;
use Mojo::Base 'Mojolicious::Command';

use Cpanel::JSON::XS 'decode_json';
use Mojo::IOLoop;
use Mojo::Promise;
use Mojo::RabbitMQ::Client;

sub run {
  my ($self, @args) = @_;

  my $status = $self->app->status;
  Mojo::IOLoop->singleton->reactor->unsubscribe('error');

  my $client
    = Mojo::RabbitMQ::Client->new(url => $self->app->config->{rabbitmq});
  my $queue_name;
  $client->connect_p->then(sub { shift->acquire_channel_p() })->then(
    sub {
      shift->declare_exchange_p(
        exchange => 'pubsub',
        type     => 'topic',
        passive  => 1,
        durable  => 1
      );
    }
  )->then(sub { shift->declare_queue_p(exclusive => 1) })->then(
    sub {
      my ($channel, $result) = @_;
      $queue_name = $result->method_frame->{queue};
      $channel->bind_queue_p(
        exchange    => 'pubsub',
        queue       => $queue_name,
        routing_key => 'suse.bot.status'
      );
    }
  )->then(
    sub {
      my $channel = shift;

      my $promise = Mojo::Promise->new;
      my $consumer = $channel->consume(queue => $queue_name, no_ack => 1);
      $consumer->on(error => sub { $promise->reject('Consumer error') });
      $consumer->on(
        message => sub {
          my $frame   = pop;
          my $message = $frame->{body}->to_raw_payload;
          my $data    = decode_json $message;
          $status->update($data);
        }
      );
      $consumer->deliver;

      return $promise;
    }
  )->catch(sub { warn shift })->wait;

}

1;

=encoding utf8

=head1 NAME

SUSE::BotStatus::Command::watcher - Status update watcher command

=head1 SYNOPSIS

  Usage: APPLICATION watcher

    script/bot_status watcher

  Options:
    -h, --help   Show this summary of available options

=cut

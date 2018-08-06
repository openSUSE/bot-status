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
package SUSE::BotStatus;
use Mojo::Base 'Mojolicious';

use Mojo::File 'path';
use Mojo::SQLite;
use SUSE::BotStatus::Model::Status;

our $VERSION = '1.0';

sub startup {
  my $self = shift;

  # Application specific commands
  push @{$self->commands->namespaces}, 'SUSE::BotStatus::Command';

  my $file = $ENV{SUSE_BOTSTATUS_CONF} || 'bot_status.conf';
  my $config = $self->plugin(Config => {file => $file});

  # Short logs for systemd
  $self->log->short(1);

  # Read "assets/assetpack.def"
  $self->plugin(AssetPack => {pipes => [qw(Css JavaScript Fetch Combine)]});
  $self->asset->process;

  # Model
  $self->helper(
    sqlite => sub { state $sqlite = Mojo::SQLite->new($config->{sqlite}) });
  $self->helper(
    status => sub {
      state $status
        = SUSE::BotStatus::Model::Status->new(sqlite => shift->sqlite);
    }
  );

  # Migrations
  my $path = $self->home->child('migrations', 'bot-status.sql');
  $self->sqlite->auto_migrate(1)->migrations->name('bot-status')
    ->from_file($path);

  # Status
  my $public = $self->routes;
  $public->get('/')->to('Status#index')->name('dashboard');
}

1;

use 5.010001;

use strict;
use warnings;
use utf8;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'SUSE::BotStatus',
  VERSION_FROM => 'lib/SUSE/BotStatus.pm',
  ABSTRACT     => 'Bot Status',
  AUTHOR       => ['Sebastian Riedel <sriedel@suse.de>'],
  LICENSE      => 'MIT',
  META_MERGE   => {
    dynamic_config => 0,
    'meta-spec'    => {version => 2},
    no_index       => {directory => ['t']},
    prereqs        => {runtime => {requires => {perl => '5.010001'}}},
    resources      => {
      bugtracker => {web => 'https://gitlab.suse.de/openSUSE/bot-status'},
      homepage   => 'https://gitlab.suse.de/openSUSE/bpt-status',
      repository => {
        type => 'git',
        url  => 'https://gitlab.suse.de/openSUSE/bot-status.git',
        web  => 'https://gitlab.suse.de/openSUSE/bot-status/issues',
      },
      x_IRC => 'irc://irc.freenode.org/#suse'
    },
  },
  PREREQ_PM => {
    'CSS::Minifier::XS'              => 0,
    'JavaScript::Minifier::XS'       => 0,
    'Cpanel::JSON::XS'               => 0,
    Mojolicious                      => '7.29',
    'Mojolicious::Plugin::AssetPack' => 0,
    'Mojo::SQLite'                   => 0,
    'Mojo::RabbitMQ::Client'         => '0.2.0'
  },
  EXE_FILES => ['script/suse_bot_status'],
  test      => {TESTS => 't/*.t t/*/*.t'}
);

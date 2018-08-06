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
package SUSE::BotStatus::Model::Status;
use Mojo::Base -base;

has 'sqlite';

sub list {
  shift->sqlite->db->select('bot_status',
    [\"*, strftime('%s', updated) as updated"],
    undef, {-asc => 'name'})->expand(json => 'meta')->hashes->to_array;
}

sub update {
  my ($self, $data) = @_;

  return unless $data->{name} && $data->{status};
  $data->{meta} = {} unless ref $data->{meta} eq 'HASH';

  my $db = $self->sqlite->db;
  my $tx = $db->begin;
  $db->delete('bot_status', {name => $data->{name}});
  $db->query(
    'insert into bot_status (name, status, comment, meta) values (?, ?, ?, ?)',
    $data->{name},
    $data->{status},
    $data->{comment},
    {json => $data->{meta}}
  ) unless $data->{status} eq 'gone';
  $tx->commit;
}

1;

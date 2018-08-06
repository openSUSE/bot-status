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
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $config = {sqlite => 'sqlite::temp:'};
my $t = Test::Mojo->new('SUSE::BotStatus' => $config);

# HTML
$t->get_ok('/')->status_is(200)->element_exists_not('body p');
$t->app->status->update({name => 'test', status => 'ok'});
$t->get_ok('/')->status_is(200)->text_like('body p', qr/test: ok/);
$t->app->status->update(
  {name => 'test', status => 'failed', comment => 'Oops!'});
$t->get_ok('/')->status_is(200)
  ->text_like('body p', qr/test: failed \(Oops!\)/);

# JSON
$t->get_ok('/?format=json')->status_is(200)->json_is('/0/name', 'test')
  ->json_is('/0/status', 'failed')->json_is('/0/comment', 'Oops!');

done_testing;

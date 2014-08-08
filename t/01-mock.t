use strict;
use warnings;

use Test::More tests => 3;

use AnyEvent::Handle;
use AnyEvent::Handle::Mock;

my $mock = AnyEvent::Handle::Mock->new;
my $h = AnyEvent::Handle->new(fh => $mock->fh);

$h->push_read(chunk => 5, sub {
    my ($h, $chunk) = @_;
    is($chunk, "Hello", 'Hello');
    $h->push_write("Response");
});

$mock->feed("Hello");

is($mock->pump(chunk => 8), 'Response');

$h->push_write("Five\n");

$mock->pump(line => sub {
    is($_[1], "Five");
});

done_testing;

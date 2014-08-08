use strict;
use warnings;

# Copy from the synopsis
# ----------------------
    use AnyEvent::Handle::Mock;

    my $mock = AnyEvent::Handle::Mock->new;

    # This code is usually in the module you want to test
    # Here is a 'reverse line' server
    my $h = AnyEvent::Handle->new(
	fh => $mock->fh,
	on_read => sub {
	    $_[0]->push_read(line => sub {
		my ($h, $line) = @_;
		$h->push_write(reverse($line)."\n");
	    });
	});

    # Tests
    use Test::More tests => 1;
    $mock->feed("Hello, world!\n");
    is($mock->pump('line'), '!dlrow ,olleH');
# ----------------------


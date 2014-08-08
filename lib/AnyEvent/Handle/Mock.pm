use strict;
use warnings;

package AnyEvent::Handle::Mock;

use AnyEvent::Handle;
use AnyEvent::Util 'portable_socketpair';

our $DELAY = 1;

sub new
{
    my $class = shift;
    my ($fh1, $fh2) = portable_socketpair;
    bless [ $fh1, AnyEvent::Handle->new(fh => $fh2) ], $class
}

sub fh
{
    $_[0]->[0]
}

sub feed
{
    shift->[1]->push_write(@_)
}

sub pump
{
    my $self = shift;

    my $cb;
    $cb = pop if ref($_[-1]) eq 'CODE';
    unless (defined(wantarray) || $cb) {
	require Carp;
	Carp::croak("pump in void context requires a callback to handle data");
    }

    my $cv = AE::cv;
    $self->[1]->push_read(@_, sub {
	    if ($cb) {
		$cv->send($cb->(@_))
	    } else {
		$cv->send($_[1])
	    }
	});
    my $t = AE::timer $DELAY, 0, sub { $cv->send('') };
    $cv->recv
}

1;

=encoding utf-8

=head1 NAME

AnyEvent::Handle::Mock - Helper for testing L<AnyEvent::Handle>-based code

=head1 SYNOPSIS

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
    ok($mock->pump('line'), '!dlrow , olleH');

=head1 DESCRIPTION

This class provides a filehandle that you can give to the L<AnyEvent::Handle>
constructor and methods to feed and pump from the handle.

=head1 METHODS

=over 4

=item C<new>

Constructor. No arguments.

=item C<fh>

Returns the file handle to give to the L<AnyEvent::Handle> constructor.

=item C<feed>

Send data. Arguments are the same as C<AnyEvent::Handle-E<gt>push_read>.

=item C<pump>

Wait for data, synchronously: the event loop will run due to C<-E<gt>recv> on
a condvar.

Arguments are the same as C<AnyEvent::Handle-E<gt>push_write> (which means you
can use any C<anyevent_read_type>), except the callback is optional. If it is
missing, the received data will be the return value of the method.

=back

=head1 AUTHOR

Olivier Mengué, L<mailto:dolmen@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright E<copy> 2014 IJENKO.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut

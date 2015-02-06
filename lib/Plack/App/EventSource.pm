package Plack::App::EventSource;
use 5.008001;
use strict;
use warnings;

use parent 'Plack::Component';

our $VERSION = "0.01";

use Plack::Util::Accessor qw(handler_cb headers);
use Plack::App::EventSource::Connection;

sub call {
    my $self = shift;
    my ($env) = @_;

    return [405, [], ['Method not allowed']]
      unless $env->{REQUEST_METHOD} eq 'GET';

    return sub {
        my $respond = shift;

        my $writer = $respond->(
            [
                200,
                [
                    'Content-Type' => 'text/event-stream; charset=UTF-8',
                    'Cache-Control' =>
                      'no-store, no-cache, must-revalidate, max-age=0',
                    'Access-Control-Allow-Methods' => 'GET',
                    @{$self->headers || []}
                ]
            ]
        );

        my $connection = Plack::App::EventSource::Connection->new(
            push_cb => sub {
                my (@messages) = @_;

                foreach my $message (@messages) {
                    if (ref $message eq 'HASH') {
                        $writer->write(
                            join "\x0d\x0a",
                            "id: $message->{id}",
                            "data: $message->{data}", ''
                        );
                    }
                    else {
                        $writer->write("data: $message\x0d\x0a");
                    }
                }

                $writer->write("\x0d\x0a");
            },
            close_cb => sub {
                $writer->close;
            }
        );

        $self->{handler_cb}->($connection, $env);
    };
}

1;
__END__
=pod

=encoding utf-8

=head1 NAME

Plack::App::EventSource - EventSource/SSE for Plack

=head1 SYNOPSIS

    use Plack::App::EventSource;
    use Plack::Builder;

    builder {
        mount '/events' => Plack::App::EventSource->new(
            handler_cb => sub {
                my ($conn, $env) = @_;

                $conn->push('foo');
                # or
                # $conn->push('foo', 'bar', 'baz');
                # or
                # $conn->push({id => 1, data => 'foo'});
                $conn->close;
            }
        )->to_app;

        mount '/' => $app;
    };

=head1 DESCRIPTION

Plack::App::EventSource is an EventSource or Server Sent Events applications.
EventSource is an alternative to WebSockets when there is no need for duplex
communication. EventSource uses HTTP and is much simpler in implementation.
Ideal for website notifications or read only update streams.

It is recommended to use EventSource with polyfills to enable them in browsers
that don't support SSE. This does not need any server changes, which is very
handy. Take a look at
L<EventSource.js|https://github.com/remy/polyfills/blob/master/EventSource.js>
and L<jquery.eventsource|https://github.com/rwaldron/jquery.eventsource>.

This library stays event loop agnostic, which means that you can use it with
L<AnyEvent> or L<POE> or even just with a plain forking server.

=head2 Options

=over

=item C<handler_cb>

The main application entry point. It is called with
L<Plack::App::EventSource::Connection> and C<$env> parameters.

    handler_cb => sub {
        my ($conn, $env) = @_;

        $conn->push('hi');
        $conn->close;
    }

=item C<headers>

Additional response headers. With is useful when you want to add Access Control
headers:

    headers => [
        'Access-Control-Allow-Origin' : 'http://localhost:5000',
        'Access-Control-Allow-Credentials' : 'true'
    ]

=back

=head1 HOWTOs

=head2 Sending cookies to another domain

Set CORS headers:

    headers => [
        'Access-Control-Allow-Origin' : 'http://original-domain',
        'Access-Control-Allow-Credentials' : 'true'
    ]

If you try to set C<Origin> to C<*> some browsers will complain. So make sure to
set the correct original domain.

When connecting to EventSource on the client side pass C<withCredentials>
option:

    var es = new EventSource("http://another-domain", {
        withCredentials: true
    });

=head1 ISA

L<Plack::Component>

=head1 METHODS

=head2 C<call($env)>

=head1 INHERITED METHODS

=head2 C<new>

=head2 C<mk_accessors>

=head2 C<prepare_app>

=head2 C<response_cb($res, $cb)>

=head2 C<to_app>

=head2 C<to_app_auto>

=head1 AUTHOR

Viacheslav Tykhanovskyi, E<lt>viacheslav.t@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

This program is distributed in the hope that it will be useful, but without any
warranty; without even the implied warranty of merchantability or fitness for
a particular purpose.

=cut

# NAME

Plack::App::EventSource - EventSource/SSE for Plack

# SYNOPSIS

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

# DESCRIPTION

Plack::App::EventSource is an EventSource or Server Side Events applications.
EventSource is an alternative to WebSockets when there is no need for duplex
communication. EventSource uses HTTP and is much simpler in implementation.
Ideal for website notifications or read only streams.

## Options

- `handler_cb`

    The main application entry point. It is called with
    [Plack::App::EventSource::Connection](https://metacpan.org/pod/Plack::App::EventSource::Connection) and `$env` parameters.

        handler_cb => sub {
            my ($conn, $env) = @_;

            $conn->push('hi');
            $conn->close;
        }

# ISA

[Plack::Component](https://metacpan.org/pod/Plack::Component)

# METHODS

## `call($env)`

# INHERITED METHODS

## `new`

## `mk_accessors`

## `prepare_app`

## `response_cb($res, $cb)`

## `to_app`

## `to_app_auto`

# AUTHOR

Viacheslav Tykhanovskyi, <viacheslav.t@gmail.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2015, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

This program is distributed in the hope that it will be useful, but without any
warranty; without even the implied warranty of merchantability or fitness for
a particular purpose.

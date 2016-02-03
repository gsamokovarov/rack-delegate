# Rack Delegate

Rack level reverse proxy. Route requests to services with pure Ruby if that's
your boat. The boat won't be pretty fast, but you can deploy it on your
Heroku's, and what-not-fancy-cloud-services, without a bit of complications.

The proxy can sit after the request authentication, or before it, depending on
the services you have to route requests to. You can rewrite requests URLs, and
even the whole `Net::HTTP::Reqest` to be sent out.

## Installation

Put this in the application `Gemfile`:

```ruby
gem 'rack-delegate'
```

`rack-delegate` requires Ruby 2.0 and above.

## Usage

To use `rack-delegate`, you first need to configure a delegator proxy. You can
do that with `Rack::Delegate.configure`. Note that `Rack::Delegate.configure`,
actually creates a middleware, which we can insert in an arbitrary stack later
on.

```ruby
Macro::ApiGateway = Rack::Delegate.configure do
  # Strips the leading /api out of the outgoing requests.
  rewrite { path.gsub!(%r{\A/api}, '') }

  # Don't proxy requests without them matching on the condition in the block.
  constraints { |request| Version.new('v1').matches?(request) }

  # With the rewrite on, requests you /api/users will go to
  # http://users-service.intern/users.
  from %r{\A/api/users},    to: 'http://users-service.intern'

  # Requests go to http://payments-service.intern/payments.
  from %r{\A/api/payments}, to: 'http://payments-service.intern'
end

module Macro
  class Appplication
    middleware.use ApiGateway
  end
end
```

Yes, you can insert multiple `Rack::Delegate` middleware instances in your
stack. Say, one for requests that don't require authentication and one for
requests that do.

_(Given that the request authentication is a middleware itself.)_

```ruby
Macro::UnauthenticatedGateway = Rack::Delegate.configure do
  rewrite { path.gsub!(%r{\A/api}, '') }

  from %r{\A/registration}, to: 'http://registration-service.intern'
end

Macro::AuthenticatedGateway = Rack::Delegate.configure do
  rewrite { path.gsub!(%r{\A/api}, '') }

  from %r{\A/api/users},    to: 'http://users-service.intern'
  from %r{\A/api/payments}, to: 'http://payments-service.intern'
end

module Macro
  class Appplication
    middleware.insert_before "Auth", UnauthenticatedGateway
    middleware.insert_after "Auth", AuthenticatedGateway
  end
end
```

## Why

![but](https://raw.githubusercontent.com/gsamokovarov/rack-delegate/master/.but.jpg)

If you wanna go the (micro) services route, you can do it quickly with Ruby and
prototype. If you need the speed, you can check out [OpenResty].

[OpenResty]: https://openresty.org/

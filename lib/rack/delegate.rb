require 'rack'

require 'rack/delegate/uri_rewriter'
require 'rack/delegate/net_http_request_builder'
require 'rack/delegate/delegator'
require 'rack/delegate/network_error_response'
require 'rack/delegate/action'
require 'rack/delegate/constrained_action'
require 'rack/delegate/configuration'
require 'rack/delegate/dispatcher'

module Rack
  module Delegate
    def self.configure(&block)
      dispatcher = Dispatcher.configure(&block)

      Struct.new(:app) do
        define_method :call do |env|
          request = Request.new(env)

          if action = dispatcher.dispatch(request)
            action.call(env)
          else
            app.call(env)
          end
        end
      end
    end
  end
end

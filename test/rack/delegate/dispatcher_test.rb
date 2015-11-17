require 'test_helper'

module Rack
  module Delegate
    class DispatcherTest < Minitest::Test
      @@env_to_dispatch = Rack::MockRequest.env_for('http://example.com/foo/42',
        'REMOTE_ADDR' => '123.123.123.123'
      )

      @@env_to_pass = Rack::MockRequest.env_for('http://example.com',
        'REMOTE_ADDR' => '123.123.123.123'
      )

      test 'dispatches requests matching a pattern' do
        request = Rack::Request.new(@@env_to_dispatch)

        assert dispatcher.dispatch(request)
      end

      test 'passes over requests not matching the pattern' do
        request = Rack::Request.new(@@env_to_pass)

        assert_nil dispatcher.dispatch(request)
      end

      def dispatcher
        Dispatcher.configure do
          from %r{\A/foo}, to: 'http://69.69.69.69/'
        end
      end
    end
  end
end

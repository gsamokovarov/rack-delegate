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

      @@env_to_pass_constraints = Rack::MockRequest.env_for('http://example.com/bar/42', {
        'REMOTE_ADDR' => '123.123.123.123'
      })

      test 'dispatches requests matching a pattern' do
        request = Rack::Request.new(@@env_to_dispatch)

        assert dispatcher.dispatch(request)
      end

      test 'passes over requests not matching the pattern' do
        request = Rack::Request.new(@@env_to_pass)

        assert_nil dispatcher.dispatch(request)
      end

      test 'passes over requests not matching constraints' do
        request = Rack::Request.new(@@env_to_pass_constraints)

        assert_nil dispatcher.dispatch(request)
      end

      def dispatcher
        nogo = Object.new.instance_eval do
          def matches?(*)
            false
          end

          self
        end

        Dispatcher.configure do
          from %r{\A/foo}, to: 'http://69.69.69.69/'
          from %r{\A/bar}, to: 'http://69.69.69.69/', constraints: nogo
        end
      end
    end
  end
end

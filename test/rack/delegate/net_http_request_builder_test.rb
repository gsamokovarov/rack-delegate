require 'test_helper'

module Rack
  module Delegate
    class NetHttpRequestBuilderTest < Minitest::Test
      @@env = Rack::MockRequest.env_for('http://example.com/prefix/foo/42',
        'REQUEST_METHOD' => 'POST',
        'REMOTE_ADDR' => '123.123.123.123',
        'HTTP_X_CUSTOM_HEADER' => '42',
        'rack.input' => StringIO.new('42')
      )

      @@request = Rack::Request.new(@@env)
      @@rewriter = UriRewriter.new { |u| u.path = u.path.gsub('/prefix', ''); u }

      test "delegates all the Rack request headers" do
        assert_equal @@env['HTTP_X_CUSTOM_HEADER'], net_http_request['X-CUSTOM-HEADER']
      end

      test "delegates the Rack request body" do
        assert_equal '42', net_http_request.body
      end

      test "strips /prefix from the request" do
        assert_equal 'http://example.com/foo/42', net_http_request.uri.to_s
      end

      def net_http_request
        NetHttpRequestBuilder.new(@@request, @@rewriter).build
      end
    end
  end
end

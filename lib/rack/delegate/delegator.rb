require 'timeout_errors'

module Rack
  module Delegate
    class Delegator
      class << self
        attr_accessor :network_error_response
      end

      def initialize(url, uri_rewriter, net_http_request_rewriter)
        @url = URI(url)
        @uri_rewriter = uri_rewriter
        @net_http_request_rewriter = net_http_request_rewriter
      end

      def call(env)
        rack_request = Request.new(env)
        net_http_request = NetHttpRequestBuilder.new(rack_request, @uri_rewriter, @net_http_request_rewriter).build

        http_response = Net::HTTP.start(*net_http_options) do |http|
          http.request(net_http_request)
        end

        convert_to_rack_response(http_response)
      rescue TimeoutErrors
        # TODO: Should I let the error in as an input?
        network_error_response.call(env)
      end

      private

      def net_http_options
        [@url.host, @url.port, https: @url.scheme == 'https']
      end

      def network_error_response
        self.class.network_error_response ||= NetworkErrorResponse
      end

      def convert_to_rack_response(http_response)
        status = http_response.code
        headers = normalize_headers_for(http_response)
        body = Array(http_response.body)

        [status, headers, body]
      end

      def normalize_headers_for(http_response)
        http_response.to_hash.tap do |headers|
          headers.delete('status')
        end
      end
    end
  end
end

require 'timeout_errors'

module Rack
  module Delegate
    class Delegator
      def initialize(url, uri_rewriter, net_http_request_rewriter, timeout_response)
        @url = URI(url)
        @uri_rewriter = uri_rewriter
        @net_http_request_rewriter = net_http_request_rewriter
        @timeout_response = timeout_response
      end

      def call(env)
        rack_request = Request.new(env)
        net_http_request = NetHttpRequestBuilder.new(rack_request, @uri_rewriter, @net_http_request_rewriter).build

        http_response = Net::HTTP.start(*net_http_options) do |http|
          http.request(net_http_request)
        end

        convert_to_rack_response(http_response)
      rescue TimeoutErrors
        @timeout_response.call(env)
      end

      private

      def net_http_options
        [@url.host, @url.port, use_ssl: @url.scheme == 'https']
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

          # Since Ruby 2.1 Net::HTTPHeader#to_hash returns the value as an
          # array of values and not a string. Try to coerce it for 2.0 support.
          headers.each { |header, value| headers[header] = Array(value).join('; ') }
        end
      end
    end
  end
end

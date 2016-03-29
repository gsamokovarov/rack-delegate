require 'net/http'

module Rack
  module Delegate
    class NetHttpRequestBuilder < Struct.new(:rack_request, :uri_rewriter, :net_http_request_rewriter)
      CONTENT_HEADERS = %w(
        CONTENT_LENGTH
        CONTENT_TYPE
      ).freeze

      def build
        net_http_request_class.new(url).tap do |net_http_request|
          delegate_rack_headers_to(net_http_request)
          delegate_rack_body_to(net_http_request)

          rewrite_net_http_request(net_http_request)
        end
      end

      private

      def http_method
        rack_request.request_method.capitalize
      end

      def net_http_request_class
        Net::HTTP.const_get(http_method)
      end

      def url
        uri_rewriter.rewrite(URI(rack_request.url))
      end

      def delegate_rack_headers_to(net_http_request)
        net_http_request.initialize_http_header(headers_from_rack_request(rack_request))
      end

      def delegate_rack_body_to(net_http_request)
        return unless net_http_request.request_body_permitted?

        begin
          net_http_request.body = rack_request.body.read
        ensure
          rack_request.body.rewind
        end
      end

      def rewrite_net_http_request(net_http_request)
        net_http_request_rewriter.rewrite(net_http_request)
      end

      def headers_from_rack_request(rack_request)
        rack_request.env
          .select  { |key, _| key.start_with?('HTTP_') || CONTENT_HEADERS.include?(key) }
          .collect { |key, value| [key.sub(/^HTTP_/, '').tr('_', '-'), value] }
      end
    end
  end
end

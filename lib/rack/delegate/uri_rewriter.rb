module Rack
  module Delegate
    class UriRewriter
      def initialize(&rewriter)
        @rewriter = rewriter
      end

      def rewrite(uri)
        rewriter.call(URI(uri))
      end

      private

      def rewriter
        @rewriter ||= proc { |uri| uri }
      end
    end
  end
end

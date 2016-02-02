module Rack
  module Delegate
    class NetHttpRequestRewriter
      def initialize(&rewriter)
        @rewriter = rewriter
      end

      def rewrite(request)
        rewriter.call(request)
      end

      private

      def rewriter
        @rewriter ||= proc { |request| request }
      end
    end
  end
end

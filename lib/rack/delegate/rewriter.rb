module Rack
  module Delegate
    class Rewriter
      def initialize(&rewriter)
        @rewriter = rewriter || proc { |id| id }
      end

      def rewrite(object)
        @rewriter.call(object)
      end
    end
  end
end

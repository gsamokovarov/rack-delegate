module Rack
  module Delegate
    class ConstrainedAction < Struct.new(:action, :constraints)
      def dispatch(request)
        if appropriate?(request)
          action.dispatch(request)
        end
      end

      private

      def appropriate?(request)
        Constraint.new(constraints) === request
      end
    end
  end
end

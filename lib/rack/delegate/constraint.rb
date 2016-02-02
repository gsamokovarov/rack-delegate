module Rack
  module Delegate
    class Constraint
      def initialize(*constraints)
        @constraints = constraints.flatten.compact
      end

      def ===(request)
        @constraints.all? do |constraint|
          constraint.matches?(request)
        end
      end
    end
  end
end


module Rack
  module Delegate
    class Constraint
      def initialize(*constraints)
        @constraints = constraints.flatten.compact
      end

      def ===(request)
        @constraints.all? do |constraint|
          invoke_polyglot_constraint(constraint, request)
        end
      end

      private

      SUPPORTED_CONSTRAINTS_INTERFACE = [:matches?, :call, :===]

      def invoke_polyglot_constraint(constraint, request)
        method = SUPPORTED_CONSTRAINTS_INTERFACE.find do |method|
          constraint.respond_to?(method)
        end
        constraint.public_send(method, request)
      end
    end
  end
end


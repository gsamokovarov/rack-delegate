module Rack
  module Delegate
    class Action < Struct.new(:pattern, :delegator)
      def dispatch(request)
        pattern.match(request.fullpath) do
          throw :dispatched, delegator
        end
      end
    end
  end
end

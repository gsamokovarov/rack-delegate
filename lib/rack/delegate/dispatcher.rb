module Rack
  module Delegate
    class Dispatcher < Struct.new(:actions)
      def self.configure(&block)
        new(Configuration.from_block(&block))
      end

      def dispatch(request)
        catch :dispatched do
          actions.each do |action|
            action.dispatch(request)
          end

          nil
        end
      end
    end
  end
end

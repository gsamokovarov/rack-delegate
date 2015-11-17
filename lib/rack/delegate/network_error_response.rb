module Rack
  module Delegate
    class NetworkErrorResponse < Struct.new(:env)
      def self.call(env)
        new(env).call
      end

      def call
        status = 504
        headers = {'Content-Type' => 'text/plain'}
        body = ["Gateway Timeout\n"]

        [status, headers, body]
      end
    end
  end
end

module Rack
  module Delegate
    class Configuration
      def self.from_block(&block)
        config = new
        config.instance_eval(&block)
        config.actions
      end

      attr_reader :actions

      def initialize
        @actions = []
        @constraints = []
        @rewriter = Rewriter.new
        @changer = Rewriter.new
        @timeout = NetworkErrorResponse
      end

      def from(pattern, to:, constraints: nil)
        action = Action.new(pattern, Delegator.new(to, @rewriter, @changer, @timeout))
        action = Rack::Timeout.new(action) if timeout?

        constraints = Array(constraints).concat(@constraints)
        action = ConstrainedAction.new(action, constraints) unless constraints.empty?

        @actions << action
      end

      def rewrite(&block)
        @rewriter = Rewriter.new do |uri|
          uri.instance_eval(&block)
          uri
        end
      end

      def change
        @changer = Rewriter.new do |request|
          yield request
          request
        end
      end

      def timeout(response_object = nil, &block)
        @timeout = response_object if response_object
        @timeout = block if block
      end

      private

      def constraints(*args, &block)
        @constraints << args.flatten << block
      end

      def timeout?
        require 'rack/timeout'
        true
      rescue LoadError
        false
      end
    end
  end
end

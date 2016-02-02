module Rack
  module Delegate
    class Configuration < Struct.new(:actions)
      def self.from_block(&block)
        config = new
        config.instance_eval(&block)
        config.actions
      end

      def initialize
        @actions = []
        @constraints = []
        @rewriter = Rewriter.new
        @changer = Rewriter.new
      end

      def from(pattern, to:, constraints: nil)
        action = Action.new(pattern, Delegator.new(to, @rewriter, @changer))
        action = Rack::Timeout.new(action) if timeout?

        constraints = Array(constraints).concat(@constraints)
        action = ConstrainedAction.new(action, constraints) unless constraints.empty?

        actions << action
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

      private

      def constraints(*args)
        @constraints << args.flatten
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

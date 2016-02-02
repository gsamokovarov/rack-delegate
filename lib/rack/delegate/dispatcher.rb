module Rack
  module Delegate
    class Dispatcher < Struct.new(:actions)
      def self.configure(&block)
        new(Config.actions_from_block(&block))
      end

      def dispatch(request)
        catch :dispatched do
          actions.each do |action|
            action.dispatch(request)
          end

          nil
        end
      end

      Action = Struct.new(:pattern, :delegator) do
        def dispatch(request)
          pattern.match(request.fullpath) do
            throw :dispatched, delegator
          end
        end
      end

      ConstrainedAction = Struct.new(:action, :constraints) do
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

      Config = Struct.new(:actions) do
        def self.actions_from_block(&block)
          config = new([])
          config.instance_eval(&block)
          config.actions
        end

        def from(pattern, to:, constraints: nil)
          action = Action.new(pattern, Delegator.new(to, rewriter, changer))
          action = Rack::Timeout.new(action) if timeout?

          if constraints = Array(constraints).concat(@constraints) and !constraints.empty?
            action = ConstrainedAction.new(action, constraints)
          end

         actions << action
        end

        def rewrite(&block)
          @rewriter = UriRewriter.new do |uri|
            uri.instance_eval(&block)
            uri
          end
        end

        def change
          @changer = NetHttpRequestRewriter.new do |request|
            yield request
            request
          end
        end

        private

        def rewriter
          @rewriter || UriRewriter.new
        end

        def changer
          @changer || NetHttpRequestRewriter.new
        end

        def constraints(*args)
          (@constraints ||= []) << args.flatten
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
end

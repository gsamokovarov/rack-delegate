require 'test_helper'

module Rack
  module Delegate
    class UriRewriterTest < Minitest::Test
      @@uri = URI('https://example.com/test/users')

      test "rewrites URI's based on an input rule" do
        assert_equal 'https://example.com/users', rewriter.rewrite(@@uri).to_s
      end

      def rewriter
        UriRewriter.new do |uri|
          uri.path = uri.path.gsub('/test', '')
          uri
        end
      end
    end
  end
end

$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'minitest/autorun'
require 'rack/delegate'

def (Minitest::Test).test(name, &block)
  define_method("test_#{name}", &block)
end

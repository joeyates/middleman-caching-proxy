$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

root = File.dirname(__FILE__)
Dir[File.join(root, "support", "**", "*.rb")].each { |f| require f }

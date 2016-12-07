require "autostruct/wrap"

module Middleman::CachingProxy
  class CacheItem
    def initialize(path:, template:, fingerprint:); end
    include Autostruct::Wrap
  end
end

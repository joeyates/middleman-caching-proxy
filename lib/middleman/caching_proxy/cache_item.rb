require "autostruct/wrap"

module Middleman::CachingProxy
  class CacheItem
    def initialize(path:, template:, proxy_options:, fingerprint:); end
    include Autostruct::Wrap
  end
end

require "autostruct/wrap"

module Middleman::CachingProxy; end

class Middleman::CachingProxy::CacheItem
  def initialize(path:, template:, proxy_options:, fingerprint:); end
  include Autostruct::Wrap
end

require "autostruct/wrap"

class CacheItem
  def initialize(path:, template:, proxy_options:, fingerprint:); end
  include Autostruct::Wrap
end

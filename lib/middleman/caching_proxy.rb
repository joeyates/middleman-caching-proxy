require "middleman-core"

require "middleman/caching_proxy/extension"

::Middleman::Extensions.register(
  :caching_proxy, Middleman::CachingProxy::Extension
)

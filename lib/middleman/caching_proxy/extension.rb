require "middleman-core"
require "semantic"

require "middleman/caching_proxy/cache"
require "middleman/caching_proxy/cache_item"
require "middleman/caching_proxy/cached_resource"

module Middleman::CachingProxy
  class Extension < ::Middleman::Extension
    option :cache_directory,
       "tmp/proxy_cache",
       "The directory where cache files will be stored"
    option :cache_key,
       nil,
       "A global cache key"

    if Semantic::Version.new(Middleman::VERSION).major >= 4
      expose_to_config :proxy_with_cache
    end

    module InstanceMethods
      def proxy_with_cache(
        path:, template:, proxy_options:, fingerprint:, &block
      )
        item = CacheItem.new(
          path: path,
          template: template,
          fingerprint: fingerprint
        )
        will_use_cache = extensions[:caching_proxy].add(item)
        if !will_use_cache
          if block
            proxy(item.path, item.template, proxy_options) { block.call }
          else
            proxy item.path, item.template, proxy_options
          end
        end
      end
    end

    attr_reader :copy_from_cache
    attr_reader :add_to_cache

    def initialize(app, options_hash = {}, &block)
      super

      if Semantic::Version.new(Middleman::VERSION).major <= 3
        app.send :include, InstanceMethods
      end

      if !options.cache_key
        raise "Please supply a cache_key value"
      end

      @copy_from_cache = []
      @add_to_cache = []
      @cache = nil
    end

    def manipulate_resource_list(resources)
      resources + cached_resources
    end

    def after_build(_builder)
      copy_new_files_to_cache
      cache.save
    end

    def add(item)
      if cache.has?(item)
        copy_from_cache << item
        true
      else
        add_to_cache << item
        false
      end
    end

    private

    def cache
      @cache ||= Cache.new(path: options.cache_directory, key: options.cache_key)
    end

    def copy_new_files_to_cache
      add_to_cache.each do |item|
        # Handle directory_indexes extension
        resource = app.sitemap.find_resource_by_path(item.path)
        build_path = relative_build_path(resource.destination_path)
        cache.add item: item, source: build_path
      end
    end

    def cached_resources
      copy_from_cache.map do |item|
        cached_path = cache.full_path(item: item)
        # TODO: Handle directory_indexes extension
        build_path = relative_build_path(item.path)
        CachedResource.new(
          path: item.path, cached_path: cached_path, build_path: build_path
        )
      end
    end

    def relative_build_path(path)
      File.join("build", path)
    end
  end
end

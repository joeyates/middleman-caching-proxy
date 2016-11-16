require "middleman-core"
require "middleman-core/sitemap/resource"
require "semantic"

class CacheItem
  attr_reader :path
  attr_reader :template
  attr_reader :proxy_options
  attr_reader :fingerprint

  def initialize(path:, template:, proxy_options:, fingerprint:)
    @path = path
    @template = template
    @proxy_options = proxy_options
    @fingerprint = fingerprint
  end
end

class CachedResource
  attr_reader :path
  attr_reader :cached_path
  attr_reader :build_path

  def initialize(path:, cached_path:, build_path:)
    @path = path
    @cached_path = cached_path
    @build_path = build_path
  end

  def destination_path
    path[1..-1]
  end

  def ext
    ""
  end

  def ignored?
    false # Seems to mean "actualyy include in build?"
  end

  def binary?
    true # Seems to mean "do a binary copy or make a rack request?"
  end

  def source_file
    cached_path
  end

  def content_type
    "text/html"
  end
end

class MiddlemanExtension < ::Middleman::Extension
  option :cache_directory,
    "tmp/proxy_cache",
    "The directory where cache files will be stored"

  if Semantic::Version.new(Middleman::VERSION).major >= 4
    expose_to_config :proxy_with_cache
  end

  attr_reader :copy_from_cache
  attr_reader :copy_to_cache

  def initialize(app, options_hash = {}, &block)
    super

    require "fileutils"

    if Semantic::Version.new(Middleman::VERSION).major <= 3
      app.send :include, InstanceMethods
    end

    @cache_manifest = nil
    @copy_from_cache = []
    @copy_to_cache = []
  end

  def after_configuration
    ensure_cache_directory
  end

  def after_build(builder)
    copy_proxied_files_to_cache
    File.open(cache_manifest_path, "w") do |f|
      f.write cache.to_json
    end
  end

  def add(item)
    if matches_cached?(item)
      copy_from_cache << item
      true
    else
      cache[item.path] = item.fingerprint
      copy_to_cache << item
      false
    end
  end

  def manipulate_resource_list(resources)
    resources + cached_resources
  end

  module InstanceMethods
    def proxy_with_cache(path:, template:, proxy_options:, fingerprint:)
      item = CacheItem.new(
        path: path,
        template: template,
        proxy_options: proxy_options,
        fingerprint: fingerprint
      )
      will_use_cache = extensions[:caching_proxy].add(item)
      if !will_use_cache
        proxy item.path, item.template, item.proxy_options
      end
    end
  end

  private

  def matches_cached?(item)
    cached_path = cache_path(item.path)
    exists = File.exist?(cached_path)
    return false if !exists
    return false if cache[item.path].nil?
    return false if cache[item.path] != item.fingerprint
    true
  end

  def copy_proxied_files_to_cache
    copy_to_cache.each do |item|
      cached_path = cache_path(item.path)
      build = build_path(item.path)
      cache_subdirectory = File.dirname(cached_path)
      FileUtils.mkdir_p cache_subdirectory
      FileUtils.cp build, cached_path
    end
  end

  def cached_resources
    copy_from_cache.map do |item|
      cached_path = cache_path(item.path)
      build = build_path(item.path)
      CachedResource.new(
        path: item.path, cached_path: cached_path, build_path: build
      )
    end
  end
    
  def cache
    return @cache_manifest if @cache_manifest
    if File.exist?(cache_manifest_path)
      @cache_manifest = JSON.load(File.read(cache_manifest_path))
    else
      @cache_manifest = {}
    end
  end

  def cache_manifest_path
    cache_path(".cache.json")
  end

  def cache_path(path)
    ::File.join(options.cache_directory, path)
  end

  def build_path(path)
    File.join("build", path)
  end

  def ensure_cache_directory
    FileUtils.mkdir_p options.cache_directory
  end
end

::Middleman::Extensions.register(:caching_proxy, MiddlemanExtension)

require "autostruct/wrap"
require "fileutils"

require "middleman/caching_proxy/cache_manifest"

class Cache
  def initialize(path:, key:)
    @manifest = nil
  end
  include Autostruct::Wrap

  def has?(item)
    cached_path = full_path(item: item)
    return false if !::File.exist?(cached_path)
    manifest.has?(item)
  end

  def add(item:, source:)
    manifest.add item
    cached_path = full_path(item: item)
    copy_in source, cached_path
  end

  def full_path(item:)
    ::File.join(path, "items", item.path)
  end

  def save
    manifest.save
  end

  private

  def manifest
    @manifest ||= CacheManifest.new(path: path, key: key)
  end

  def copy_in(source, cached_path)
    cache_subdirectory = ::File.dirname(cached_path)
    FileUtils.mkdir_p cache_subdirectory

    FileUtils.cp source, cached_path
  end
end

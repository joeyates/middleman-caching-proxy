require "autostruct/wrap"
require "fileutils"

require "middleman/caching_proxy/version"

class Middleman::CachingProxy::CacheManifest
  FILENAME = ".manifest.json"
  KEY = "key"
  ITEMS = "items"
  VERSION = "version"

  def initialize(path:, key:)
    @manifest = nil
    @items = nil
  end
  include Autostruct::Wrap

  def has?(item)
    items[item.path] == item.fingerprint
  end

  def add(item)
    items[item.path] = item.fingerprint
  end

  def save
    ensure_cache_directory

    File.write manifest_path, build(items: items).to_json
  end

  private 

  def items
    @items ||= manifest[ITEMS]
  end

  def manifest_path
    ::File.join(path, FILENAME)
  end

  def manifest
    return @manifest if @manifest
    @manifest = build
    if File.exist?(manifest_path)
      from_disk = JSON.load(File.read(manifest_path))
      if is_ok?(from_disk)
        @manifest = from_disk
      end
    end
    @manifest
  end

  def is_ok?(manifest)
    return false if manifest.nil?
    return false if manifest[VERSION] != version
    # Clear cache if key changes
    return false if manifest[KEY] != key
    return false if !manifest[ITEMS].is_a?(Hash)
    true
  end

  def build(items: {})
    {
      KEY => key,
      ITEMS => items,
      VERSION => version
    }
  end

  def version
    Middleman::CachingProxy::VERSION
  end

  def ensure_cache_directory
    FileUtils.mkdir_p path
  end
end

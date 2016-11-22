require "autostruct/wrap"

class CachedResource
  def initialize(path:, cached_path:, build_path:); end
  include Autostruct::Wrap

  def destination_path
    path[1..-1]
  end

  def ext
    ""
  end

  def ignored?
    false # Seems to mean "actually include in build?"
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

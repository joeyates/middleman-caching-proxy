require "spec_helper"
require "middleman/caching_proxy/cache_item"

RSpec.describe Middleman::CachingProxy::CacheItem do
  describe ".new" do
    %w(path template fingerprint).each do |param|
      it "requires a #{param} parameter" do
        expect(described_class).to require_parameter(param)
      end
    end
  end
end

require "spec_helper"
require "middleman/caching_proxy/version"

describe Middleman::CachingProxy do
  it "has a version number" do
    expect(Middleman::CachingProxy::VERSION).not_to be nil
  end
end

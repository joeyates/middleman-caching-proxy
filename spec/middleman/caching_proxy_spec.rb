require "spec_helper"
require "middleman-core"

RSpec.describe Middleman::CachingProxy do
  before do
    allow(Middleman::Extensions).to receive(:register)
  end

  it "registers the extension" do
    require "middleman/caching_proxy"
    expect(Middleman::Extensions).
      to have_received(:register).with(
           :caching_proxy, Middleman::CachingProxy::Extension
         )
  end
end

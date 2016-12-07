require "spec_helper"
require "middleman/caching_proxy/cached_resource"

RSpec.describe Middleman::CachingProxy::CachedResource do
  describe ".new" do
    %w(path cached_path build_path).each do |param|
      it "requires a #{param} parameter" do
        expect(described_class).to require_parameter(param)
      end
    end
  end

  let(:path) { "/foo/bar" }
  let(:cached_path) { "/cached/path" }
  let(:build_path) { "/build/path" }

  subject do
    described_class.new(
      path: path, cached_path: cached_path, build_path: build_path
    )
  end

  describe "#destination_path" do
    it "is the path without the leading slash" do
      expect(subject.destination_path).to eq("foo/bar")
    end
  end

  describe "#ignored?" do
    it { is_expected.to_not be_ignored }
  end

  describe "#binary?" do
    it { is_expected.to be_binary }
  end

  describe "#ext" do
    it "is an empty string" do
      expect(subject.ext).to eq("")
    end
  end

  describe "#source_file" do
    it "is the cached path" do
      expect(subject.source_file).to eq(cached_path)
    end
  end

  describe "#content_type" do
    it "is HTML" do
      expect(subject.content_type).to eq("text/html")
    end
  end

  describe "#data" do
    it "is is an object with indifferent access" do
      expect do
        subject.data
      end.not_to raise_error
    end
  end
end

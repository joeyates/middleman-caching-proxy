require "spec_helper"
require "middleman/caching_proxy/cache"
require "middleman/caching_proxy/cache_item"

module Middleman::CachingProxy
  RSpec.describe Cache do
    let(:manifest) do
      instance_double(CacheManifest, has?: in_manifest, add: nil, save: nil)
    end
    let(:cache_path) { "/cache/path" }
    let(:key) { "key" }
    let(:in_manifest) { true }
    let(:item) { double(CacheItem, path: item_path) }
    let(:item_path) { "item/path" }
    let(:item_cache_path) { File.join(cache_path, "items", item_path) }
    let(:item_cache_directory) { File.dirname(item_cache_path) }
    let(:item_build_path) { File.join(build_path, item_path) }
    let(:build_path) { "/build/path" }

    subject { described_class.new(path: cache_path, key: key) }

    before do
      allow(CacheManifest).to receive(:new) { manifest }
    end

    describe ".new" do
      %w(path key).each do |param|
        it "requires a #{param} parameter" do
          expect(described_class).to require_parameter(param)
        end
      end
    end

    describe "#has?" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(item_cache_path) { exists }
      end

      context "when the file exists on disk" do
        let(:exists) { true }

        context "when the item is in the manifest" do
          let(:in_manifest) { true }

          it "is true" do
            expect(subject.has?(item)).to be_truthy
          end
        end

        context "when the item is not in the manifest" do
          let(:in_manifest) { false }

          it "is true" do
            expect(subject.has?(item)).to be_falsey
          end
        end
      end

      context "when the file does not exist on disk" do
        let(:exists) { false }

        it "is false" do
          expect(subject.has?(item)).to be_falsey
        end
      end
    end

    describe "#add" do
      before do
        allow(FileUtils).to receive(:mkdir_p).with(item_cache_directory)
        allow(FileUtils).to receive(:cp).with(item_build_path, item_cache_path)

        subject.add(item: item, source: item_build_path)
      end

      it "adds the item to the manifest" do
        expect(manifest).to have_received(:add).with(item)
      end

      it "ensures the cache directory exists" do
        expect(FileUtils).to have_received(:mkdir_p).with(item_cache_directory)
      end

      it "copies the file" do
        expect(FileUtils). to have_received(:cp).with(
          item_build_path, item_cache_path
        )
      end
    end

    describe "#save" do
      it "saves the manifest" do
        subject.save

        expect(manifest).to have_received(:save)
      end
    end
  end
end

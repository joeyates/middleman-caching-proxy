require "spec_helper"
require "middleman/caching_proxy/cache_manifest"
require "middleman/caching_proxy/cache_item"

module Middleman::CachingProxy
  RSpec.describe CacheManifest do
    let(:path) { "path" }
    let(:key) { "key" }
    let(:manifest_path) { File.join(path, ".manifest.json") }
    let(:manifest_exists) { true }
    let(:item) { double(CacheItem, path: item_path, fingerprint: fingerprint) }
    let(:item_path) { "item/path" }
    let(:fingerprint) { "fingerprint" }
    let(:initial_contents) { JSON.generate(initial_data) }
    let(:initial_data) do
      {
        "version" => VERSION,
        "key" => key,
        "items" => initial_items
      }
    end
    let(:initial_items) { {} }

    subject { described_class.new(path: path, key: key) }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(manifest_path) { manifest_exists }
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(manifest_path) { initial_contents }
    end

    describe "#has?" do
      context "when the item was in the JSON file" do
        let(:initial_items) { {item_path => fingerprint} }

        it "is true" do
          expect(subject.has?(item)).to be_truthy
        end
      end

      context "when the item was not in the JSON file" do
        it "is false" do
          expect(subject.has?(item)).to be_falsey
        end
      end

      context "when the JSON file did not get loaded" do
        let(:manifest_exists) { false }

        it "is false" do
          expect(subject.has?(item)).to be_falsey
        end
      end

      context "when the item was added" do
        it "is true" do
          subject.add(item)
          expect(subject.has?(item)).to be_truthy
        end
      end
    end

    describe "#save" do
      let(:initial_items) { {"foo" => "bar"} }

      before do
        @parsed = nil
        allow(File).to receive(:write).with(manifest_path, anything) do |_, j|
          @parsed = JSON.load(j)
        end
        subject.save
      end

      it "saves to disk" do
        expect(File).to have_received(:write)
      end
      
      it "saves the version" do
        expect(@parsed["version"]).to eq(VERSION)
      end

      it "saves the key" do
        expect(@parsed["key"]).to eq(key)
      end

      it "re-saves initial items" do
        expect(@parsed["items"]["foo"]).to eq("bar")
      end
    end

    describe "#add" do
      before do
        @parsed = nil
        allow(File).to receive(:write).with(manifest_path, anything) do |_, j|
          @parsed = JSON.load(j)
        end
      end

      it "is saved in the disk format" do
        subject.add(item)
        subject.save

        expect(@parsed["items"][item_path]).to eq(fingerprint)
      end
    end
  end
end

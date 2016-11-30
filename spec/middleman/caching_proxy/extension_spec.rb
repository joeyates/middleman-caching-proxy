require "spec_helper"
require "middleman/caching_proxy/extension"

module Middleman::CachingProxy
  RSpec.describe Extension do
    let(:app) do
      double(
        Middleman::Application,
        initialized: "initialized",
        instance_available: "instance_available",
        after_configuration: "after_configuration",
        after_build: "after_build",
        include: "include",
        sitemap: sitemap
      )
    end
    let(:sitemap) { nil }
    let(:options) { {cache_key: cache_key} }
    let(:cache_key) { "cache_key" }
    let(:item) { double(CacheItem, path: "path") }
    let(:cache) { double(Cache, has?: has, full_path: "", add: nil, save: nil) }
    let(:cached_resource) { double(CachedResource) }

    subject do
      described_class.new(app, options)
    end

    before do
      allow(Cache).to receive(:new) { cache }
      allow(CachedResource).to receive(:new) { cached_resource }
    end

    describe ".new" do
      context "under Middleman 3" do
        subject! { super() }

        it "adds #proxy_with_cache to the app" do
          expect(app).
            to have_received(:include).with(Extension::InstanceMethods)
        end
      end

      context "when the cache_key is not supplied" do
        let(:options) { {} }

        it "fails" do
          expect do
            subject
          end.to raise_error(RuntimeError, /supply a cache_key/)
        end
      end
    end

    context "options" do
      let(:default_cache_path) { "tmp/proxy_cache" }

      context "the cache_directory option" do
        it "defaults to a tmp path" do
          expect(subject.options.cache_directory).to eq(default_cache_path)
        end
      end

      it "has a cache_key option" do
        expect(subject.options.cache_key).to eq(cache_key)
      end
    end

    context "#add" do
      context "with cached items" do
        let(:has) { true }

        it "is true" do
          expect(subject.add(item)).to be_truthy
        end
      end

      context "with uncached items" do
        let(:has) { false }

        it "is false" do
          expect(subject.add(item)).to be_falsey
        end
      end
    end

    context "#manipulate_resource_list" do
      let(:initial) { [:array] }

      context "cached items" do
        let(:has) { true }
        let(:added) { [cached_resource] }

        specify "are added to the resources" do
          subject.add(item)

          expect(subject.manipulate_resource_list(initial)).
            to eq(initial + added)
        end
      end

      context "uncached items" do
        specify "are not added to the resources" do
          expect(subject.manipulate_resource_list(initial)).
            to eq(initial)
        end
      end
    end

    context "#after_build" do
      let(:sitemap) { double("Sitemap", find_resource_by_path: uncached) }
      let(:uncached) { double("Resource", destination_path: destination_path) }
      let(:destination_path) { "destination_path" }
      let(:build_path) { File.join("build", destination_path) }
      let(:has) { true }

      context "uncached items" do
        let(:has) { false }

        specify "are added to the cache" do
          subject.app = app
          subject.add(item)

          subject.after_build(:_builder)

          expect(cache).
            to have_received(:add).with(item: item, source: build_path)
        end
      end

      it "saves the cache" do
        subject.after_build(:_builder)

        expect(cache).to have_received(:save).with(no_args)
      end
    end

    class AppWithExtension
      attr_accessor :extensions

      def self.initialized
      end

      def self.instance_available
      end

      def self.after_configuration
      end

      def self.after_build
      end
    end

    describe Extension::InstanceMethods do
      let(:caching_proxy) { double(Extension, add: will_use_cache) }
      let(:will_use_cache) { false }
      let(:item) { double(CacheItem, args) }
      let(:args) do
        {path: "p", template: "t", proxy_options: {}, fingerprint: "f"}
      end

      subject { AppWithExtension.new }

      before do
        allow(CacheItem).to receive(:new) { item }
        Extension.new(AppWithExtension, {cache_key: ""})

        subject.extensions = {caching_proxy: caching_proxy}
        allow(subject).to receive(:proxy)
      end

      describe "#proxy_with_cache" do
        before do
          subject.proxy_with_cache(args)
        end

        it "adds the item to the caching proxy" do
          expect(caching_proxy).to have_received(:add).with(item)
        end

        context "when add returns true" do
          let(:will_use_cache) { true }

          it "does not proxy the item" do
            expect(subject).to_not have_received(:proxy)
          end
        end

        context "when add returns false" do
          let(:will_use_cache) { false }

          it "proxies the item" do
            expect(subject).to have_received(:proxy)
          end
        end
      end
    end
  end
end

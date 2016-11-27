# Middleman::CachingProxy

Caches the result of `proxy` calls allong with the fingerprint of their inputs.
If the inputs remain the same, uses the cached version.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'middleman-caching-proxy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install middleman-caching-proxy

## Usage

In `config.rb`:

```ruby
git_head = `git rev-parse HEAD`.chomp

activate :caching_proxy, cache_key: git_head

things = [...]

things.each do |thing|
  proxy_with_cache(
    path: "/things/#{thing.slug}",
    template: "/templates/thing_template.html",
    proxy_options: {locals: {thing: thing}},
    fingerprint: thing.updated_at.to_i
  )
end
```

There are 4 required parameters:

* `path`: the page path,
* `template`: the page template,
* `proxy_options`: options to pass to the `proxy` invocation,
* `fingerprint`: a value that indicates the 'version' of the item. If this
  value changes, the cached version will be skipped and updated.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you
to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/joeyates/middleman-caching-proxy. This project is intended
to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code
of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

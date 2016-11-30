require "capybara"
require 'middleman-core'

module Turnip::Steps
  include Capybara::DSL
end

# Adapted from middleman-core

step "the Server is running" do
  if exist? 'source'
    set_environment_variable 'MM_SOURCE', 'source'
  else
    set_environment_variable 'MM_SOURCE', ''
  end

  set_environment_variable 'MM_ROOT', expand_path('.')

  initialize_commands = @initialize_commands || []
  initialize_commands.unshift lambda {
    set :environment, @current_env || :development
    set :show_exceptions, false
  }

  cd '.' do
    with_environment do
      @server_inst = Middleman::Application.server.inst do
        initialize_commands.each do |p|
          instance_exec(&p)
        end
      end
    end
  end

  Capybara.app = @server_inst.class.to_rack_app
end

step "the Server is running at :fixture_path" do |fixture_path|
  step "a fixture app #{fixture_path}"
  step "the Server is running"
end

step "I go to :url" do |url|
  visit(URI.encode(url).to_s)
end

step "I should see :expected" do |expected|
  cd '.' do
    with_environment do
      expect(page.body).to include(expected)
    end
  end
end

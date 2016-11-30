require "fileutils"

acceptance_path = File.expand_path("..", __dir__)

# adapted from aruba/cucumber.rb

step "a directory named :path" do |path|
  create_directory path
end

placeholder :command do
  match /[^`]+/ do |command|
    command
  end
end

step "I run `:command`" do |command|
  run_simple(sanitize_text(command), false)
end

step "the exit status should be :exit_status" do |exit_status|
  expect(last_command_started).to have_exit_status(exit_status.to_i)
end

step "a/the directory named :directory should exist" do |directory|
  expect(directory).to be_an_existing_directory
end

step "a/the file :file should contain :partial_content" do |file, partial_content|
  expect(file).to have_file_content(Regexp.compile(Regexp.escape(partial_content)))
end

# adapted from aruba/cucumber/file.rb

step "I cd to :path" do |path|
  cd(path)
end

# Adapted from middleman-core:
# lib/middleman-core/step_definitions/middleman_steps.rb

step "a fixture app :fixture_path" do |fixture_path|
  delete_environment_variable "MM_ROOT"

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(expand_path(".")) == fixture_path

  step "a directory named #{fixture_path}"

  target_path = File.join(acceptance_path, "fixtures", fixture_path)
  FileUtils.cp_r(target_path, expand_path("."))

  step "I cd to #{fixture_path}"
end

require "fileutils"

acceptance_path = File.expand_path("..", __dir__)

# Adapted from middleman-core:
# lib/middleman-core/step_definitions/middleman_steps.rb

step "a fixture app :fixture_path" do |fixture_path|
  delete_environment_variable "MM_ROOT"

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(expand_path(".")) == fixture_path

  step "a directory named \"#{fixture_path}\""

  target_path = File.join(acceptance_path, "fixtures", fixture_path)
  FileUtils.cp_r(target_path, expand_path("."))

  step "I cd to \"#{fixture_path}\""
end

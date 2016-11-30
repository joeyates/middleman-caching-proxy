# Adapted from middleman-core/step_definitions/builder_steps.rb

step "a built app at :path" do |path|
  step "a fixture app #{path}"
  step "I run `middleman build --verbose`"
end

step "was successfully built" do
  step "the exit status should be 0"
  step "a directory named \"build\" should exist"
end

step "a successfully built app at :path" do |path|
  step "a built app at #{path}"
  step "was successfully built"
end

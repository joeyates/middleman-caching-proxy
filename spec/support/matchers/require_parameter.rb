RSpec::Matchers.define :require_parameter do |expected|
  match do |klass|
    @actual = nil

    begin
      klass.new
    rescue => ex
      @actual = ex
    end

    @actual &&
      @actual.is_a?(ArgumentError) &&
      @actual.message.match(matcher_for(expected))
  end

  def matcher_for(param)
    Regexp.new("missing keywords: .*?\\b#{param}\\b")
  end

  def failure_message
    msg = "The constructor should require #{expected}"

    if @actual
      if @actual.is_a?(ArgumentError) &&
         @actual.message.start_with?("missing keywords: ")
        m = /missing keywords: (.*)$/.match(@actual.message)
        msg << ", actually requires #{m[1]}"
      else
        msg << ", actually failed with the message '#{@actual.message}'"
      end
    else
      msg << ", but does not require any parameters."
    end

    msg
  end

  def failure_message_for_should
    failure_message
  end

  def failure_message_when_negated
    msg  = "FFFFFFUUUUUUUUUUUUUUUUUUUUUUUUU Block should not have failed with #{expected[:klass]}, with message including '#{expected[:message]}'"
    msg << ", but did."

    msg
  end

  def failure_message_for_should_not
    failure_message_when_negated
  end
end

# This code is derived from shoulda-matchers version 2.7.0

RSpec::Matchers.define :raise_error_matching do |klass: StandardError, message:|
  def supports_block_expectations?
    true
  end

  match do |block|
    @actual = nil

    begin
      block.call
    rescue => ex
      @actual = ex
    end

    @actual &&
      @actual.is_a?(klass) &&
      @actual.message.match(message)
  end

  def failure_message
    msg = "Block should have failed with #{expected[:klass]}, with a message matching '#{expected[:message]}'"

    if @actual
      if !@actual.is_a?(expected[:klass])
        msg << ", actually failed with #{@actual.class} '#{@actual.message}'"
      else
        msg << ", actually failed with the message '#{@actual.message}'"
      end
    else
      msg << ", but did not fail."
    end

    msg
  end

  def failure_message_for_should
    failure_message
  end

  def failure_message_when_negated
    msg  = "Block should not have failed with #{expected[:klass]}, with message including '#{expected[:message]}'"
    msg << ", but did."

    msg
  end

  def failure_message_for_should_not
    failure_message_when_negated
  end
end

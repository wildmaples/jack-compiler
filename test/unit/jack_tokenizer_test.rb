require "test_helper"
require "jack_tokenizer"

class JackTokenizerTest < Minitest::Test
  def test_has_more_tokens_returns_false_when_no_tokens
    io = StringIO.new
    jack_tokenizer = JackTokenizer.new(io)
    refute(jack_tokenizer.has_more_tokens?)
  end
end

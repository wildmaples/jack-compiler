require "test_helper"
require "jack_tokenizer"

class JackTokenizerTest < Minitest::Test
  def test_has_more_tokens_returns_false_when_no_tokens
    io = StringIO.new
    jack_tokenizer = JackTokenizer.new(io)
    refute(jack_tokenizer.has_more_tokens?)
  end

  def test_has_more_tokens_returns_true_when_tokens_available
    io = StringIO.new("class Foo { }")
    jack_tokenizer = JackTokenizer.new(io)
    assert(jack_tokenizer.has_more_tokens?)
  end

  def test_advance_to_end_of_file
    io = StringIO.new("class Foo { }")
    jack_tokenizer = JackTokenizer.new(io)
    4.times do
      jack_tokenizer.has_more_tokens?
      jack_tokenizer.advance
    end
    refute(jack_tokenizer.has_more_tokens?)
  end
end

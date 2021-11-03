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

  def test_advance_with_multiple_whitespace
    skip
  end

  def test_token_type_for_symbol
    io = StringIO.new("{")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:SYMBOL, jack_tokenizer.token_type)
  end

  def test_token_type_for_another_symbol
    io = StringIO.new("~")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:SYMBOL, jack_tokenizer.token_type)
  end

  def test_token_type_for_key_word
    io = StringIO.new("class")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:KEYWORD, jack_tokenizer.token_type)
  end

  def test_token_type_for_another_key_word
    io = StringIO.new("static")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:KEYWORD, jack_tokenizer.token_type)
  end

  def test_token_type_for_identifiers
    io = StringIO.new("FooBar")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:IDENTIFIER, jack_tokenizer.token_type)
  end

  def test_token_type_for_identifiers_with_special_chars
    io = StringIO.new("Foo_Bar1")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:IDENTIFIER, jack_tokenizer.token_type)
  end

  def test_token_type_for_int_values
    io = StringIO.new("999")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:INT_CONST, jack_tokenizer.token_type)
  end

  def test_token_type_for_string_values
    io = StringIO.new('"a"')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
  end

  def test_token_type_for_string_values_with_spaces
    io = StringIO.new('"a foo bar"')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    refute(jack_tokenizer.has_more_tokens?)
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
  end

  def test_string_val_returns_string_token
    io = StringIO.new('"a"')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal("a", jack_tokenizer.string_val)
  end

  def test_string_val_returns_string_token_with_spaces
    io = StringIO.new('"a foo bar"')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal("a foo bar", jack_tokenizer.string_val)
  end

  def test_string_val_returns_string_token_with_spaces_2
    io = StringIO.new('" a foo bar"')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal(" a foo bar", jack_tokenizer.string_val)
  end

  def test_string_val_returns_string_token_with_spaces_3
    io = StringIO.new('"a foo bar "')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal("a foo bar ", jack_tokenizer.string_val)
  end

  def test_string_val_returns_string_token_with_spaces_4
    io = StringIO.new('" a foo bar "')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal(" a foo bar ", jack_tokenizer.string_val)
  end

  def test_string_val_returns_string_token_with_spaces_5
    io = StringIO.new('" a foo    bar "')
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    assert_equal(:STRING_CONST, jack_tokenizer.token_type)
    assert_equal(" a foo    bar ", jack_tokenizer.string_val)
  end

  def test_int_val_returns_integer
    io = StringIO.new("999")
    jack_tokenizer = JackTokenizer.new(io)
    jack_tokenizer.has_more_tokens?
    jack_tokenizer.advance
    jack_tokenizer.token_type
    assert_equal(999, jack_tokenizer.int_val)
  end

  # def test_identifier_returns_string_identifier
  #   io = StringIO.new("FooBar")
  #   jack_tokenizer = JackTokenizer.new(io)
  #   jack_tokenizer.has_more_tokens?
  #   jack_tokenizer.advance
  #   jack_tokenizer.token_type
  #   assert_equal("FooBar", jack_tokenizer.identifier)
  # end

  # def test_identifier_returns_string_identifier_special_characters
  #   io = StringIO.new("Foo_Bar1")
  #   jack_tokenizer = JackTokenizer.new(io)
  #   jack_tokenizer.has_more_tokens?
  #   jack_tokenizer.advance
  #   jack_tokenizer.token_type
  #   assert_equal("Foo_Bar1", jack_tokenizer.identifier)
  # end

  # def test_symbol_returns_symbol
  #   io = StringIO.new("~")
  #   jack_tokenizer = JackTokenizer.new(io)
  #   jack_tokenizer.has_more_tokens?
  #   jack_tokenizer.advance
  #   jack_tokenizer.token_type
  #   assert_equal("~", jack_tokenizer.symbol)
  # end

  # def test_symbol_returns_key_world
  #   io = StringIO.new("class")
  #   jack_tokenizer = JackTokenizer.new(io)
  #   jack_tokenizer.has_more_tokens?
  #   jack_tokenizer.advance
  #   jack_tokenizer.token_type
  #   assert_equal(:CLASS, jack_tokenizer.key_word)
  # end
end

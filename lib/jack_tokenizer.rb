class JackTokenizer
  def initialize(io)
    @input = io.read
    @index = 0
  end

  def has_more_tokens?
    @index < @input.length
  end

  def advance
    next_index = @input.index(" ", @index)
    current_chars = @input[@index...next_index]

    if SYMBOL_TOKENS.include?(current_chars)
      @token_type = :SYMBOL
    elsif KEYWORD_TOKENS.include?(current_chars)
      @token_type = :KEYWORD
    elsif DIGITS.include?(current_chars[0])
      @token_type = :INT_CONST
    elsif current_chars.start_with?('"')
      @token_type = :STRING_CONST
    else
      @token_type = :IDENTIFIER
    end

    if next_index.nil?
      @index = @input.length
    else
      @index = next_index + 1
    end
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]
  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9]

  def token_type
    @token_type
  end

  def key_word
  end

  def symbol
  end

  def identifier
  end

  def int_val
  end

  def string_val
  end
end

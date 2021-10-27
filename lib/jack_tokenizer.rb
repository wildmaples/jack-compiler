class JackTokenizer
  def initialize(io)
    @raw_tokens = io.read.split(" ")
  end

  def has_more_tokens?
    !@raw_tokens.empty?
  end

  def advance
    @current_raw_token = @raw_tokens.shift
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]
  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]

  def token_type
    begin
      Integer(@current_raw_token)
      return :INT_VAL
    rescue ArgumentError; end

    if @current_raw_token.start_with?('"')
      handle_string_values
    elsif SYMBOL_TOKENS.include?(@current_raw_token)
      :SYMBOL
    elsif KEYWORD_TOKENS.include?(@current_raw_token)
      :KEYWORD
    elsif @current_raw_token.is_a?(String)
      :IDENTIFIER
    end
  end

  def handle_string_values
    if @current_raw_token.start_with?('"') && @current_raw_token.end_with?('"')
      :STRING_VAL
    end
  end

  def key_word
    raise NotImplementedError
  end

  def symbol
    raise NotImplementedError
  end

  def identifier
    raise NotImplementedError
  end

  def int_val
    raise NotImplementedError
  end

  def string_val
    raise NotImplementedError
  end
end

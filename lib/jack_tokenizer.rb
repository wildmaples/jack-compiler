class JackTokenizer
  def initialize(io)
    @raw_tokens = io.read.split(" ")
  end

  def has_more_tokens?
    !@raw_tokens.empty?
  end

  def advance
    @current_token = @raw_tokens.shift
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]
  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]

  def token_type
    begin
      Integer(@current_token)
      return :INT_CONST
    rescue ArgumentError; end

    if @current_token.start_with?('"')
      handle_string_values
    elsif SYMBOL_TOKENS.include?(@current_token)
      :SYMBOL
    elsif KEYWORD_TOKENS.include?(@current_token)
      :KEYWORD
    elsif @current_token.is_a?(String)
      :IDENTIFIER
    end
  end

  def handle_string_values
    if @current_token.start_with?('"') && @current_token.end_with?('"')
      @current_token = @current_token[1..-2]
      :STRING_CONST
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
    @current_token
  end
end

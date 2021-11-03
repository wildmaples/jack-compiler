class JackTokenizer
  def initialize(io)
    @raw_tokens = io.read.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
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
      :STRING_CONST
    elsif SYMBOL_TOKENS.include?(@current_token)
      :SYMBOL
    elsif KEYWORD_TOKENS.include?(@current_token)
      :KEYWORD
    elsif @current_token.is_a?(String)
      :IDENTIFIER
    end
  end

  def key_word
    @current_token.upcase.to_sym
  end

  def symbol
    @current_token
  end

  def identifier
    @current_token
  end

  def int_val
    Integer(@current_token)
  end

  def string_val
    @current_token[1..-2]
  end
end

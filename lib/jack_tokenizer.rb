class JackTokenizer
  def initialize(io)
    @input = io.read
    @index = 0
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]
  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9]
  WHITESPACES = [" ", "\n"]

  def has_more_tokens?
    loop do
      old_index = @index
      skip_whitespace
      skip_comments
      break if old_index == @index
    end

    @index < @input.length
  end

  def advance
    if (match = @input.match(%r{"[^"]*"}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      next_index = match.end(0)
    elsif (match = @input.match(%r{[_a-zA-Z][_a-zA-Z0-9]*}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      next_index = match.end(0)
    elsif (match = @input.match(%r{[{}()\[\].,;+\-*/&|<>=~]}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      next_index = match.end(0)
    elsif (match = @input.match(%r{[0-9]+}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      next_index = match.end(0)
    end

    if SYMBOL_TOKENS.include?(@current_token)
      @token_type = :SYMBOL
    elsif KEYWORD_TOKENS.include?(@current_token)
      @token_type = :KEYWORD
    elsif DIGITS.include?(@current_token[0])
      @token_type = :INT_CONST
    elsif @current_token.start_with?('"')
      @token_type = :STRING_CONST
    else
      @token_type = :IDENTIFIER
    end

    @index = next_index
  end

  def token_type
    @token_type
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
    @current_token.to_i
  end

  def string_val
    @current_token[1...-1]
  end

  private

  def skip_whitespace
    while WHITESPACES.include?(@input[@index])
      @index += 1
    end
  end

  def skip_comments
    if @input[@index..@index+1] == "//"
      @index = @input.index("\n", @index) || @input.length

    elsif @input[@index..@index+1] == "/*"
      @index = @input.index("*/", @index) + 2
    end
  end
end

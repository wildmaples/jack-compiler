class JackTokenizer
  def initialize(io)
    @input = io.read
    @index = 0
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]

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
      @index = match.end(0)
      @token_type = :STRING_CONST
    elsif (match = @input.match(%r{[_a-zA-Z][_a-zA-Z0-9]*}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      @index = match.end(0)
      if KEYWORD_TOKENS.include?(@current_token)
        @token_type = :KEYWORD
      else
        @token_type = :IDENTIFIER
      end
    elsif (match = @input.match(%r{[{}()\[\].,;+\-*/&|<>=~]}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      @index = match.end(0)
      @token_type = :SYMBOL
    elsif (match = @input.match(%r{[0-9]+}, @index)) && match.begin(0) == @index
      @current_token = match[0]
      @index = match.end(0)
      @token_type = :INT_CONST
    end
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
    if (match = @input.match(%r{[ \n]*}, @index)) && match.begin(0) == @index
      @index = match.end(0)
    end
  end

  def skip_comments
    if (match = @input.match(%r{//.*$}, @index)) && match.begin(0) == @index
      @index = match.end(0)

    elsif (match = @input.match(%r{/\*(.|\n)*\*/}, @index)) && match.begin(0) == @index
      @index = match.end(0)
    end
  end
end

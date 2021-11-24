class JackTokenizer
  def initialize(io)
    @input = io.read
    @index = 0
  end

  KEYWORD_TOKENS = %w[class method function constructor int boolean char void var static field let do if else while return true false null this]
  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9]
  WHITESPACES = [" ", "\n"]
  LETTERS = ("a".."z").to_a + ("A".."Z").to_a

  def has_more_tokens?
    loop do
      old_index = @index

      while WHITESPACES.include?(@input[@index])
        @index += 1
      end

      if @input[@index] == "/" && @input[@index+1] == "/"
        @index = @input.index("\n", @index) || @input.length

      elsif @input[@index] == "/" && @input[@index+1] == "*"
        @index = @input.index("*/", @index) + 2
      end

      break if old_index == @index
    end

    @index < @input.length
  end

  def advance
    if @input[@index] == '"'
      next_index = @input.index('"', @index + 1) + 1
    elsif is_start_of_identifier?(@input[@index])
      next_index = @index
      while is_body_of_identifier?(@input[next_index])
        next_index += 1
      end
    elsif SYMBOL_TOKENS.include?(@input[@index])
      next_index = @index + 1
    elsif DIGITS.include?(@input[@index])
      next_index = @index
      while DIGITS.include?(@input[next_index])
        next_index += 1
      end
    end

    @current_token = @input[@index...next_index]

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

  def is_start_of_identifier?(char)
    char == "_" || LETTERS.include?(char)
  end

  def is_body_of_identifier?(char)
    is_start_of_identifier?(char) || DIGITS.include?(char)
  end
end

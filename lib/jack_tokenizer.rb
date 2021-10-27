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

  SYMBOL_TOKENS =  %w[{ } ( ) [ ] . , ; + - * / & | < > = ~]

  def token_type
    if SYMBOL_TOKENS.include?(@current_raw_token)
      :SYMBOL
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

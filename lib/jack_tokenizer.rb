class JackTokenizer
  def initialize(io)
    @raw_tokens = io.read.split(" ")
  end

  def has_more_tokens?
    !@raw_tokens.empty?
  end

  def advance
    @raw_tokens.shift
  end

  def token_type
    raise NotImplementedError
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

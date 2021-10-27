class JackTokenizer
  def initialize(io)
    @io = io
  end

  def has_more_tokens?
    !@io.eof?
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

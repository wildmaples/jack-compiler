class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
  end

  def compile_class
    @output.puts("<class>")
    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<keyword> class </keyword>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<identifier> #{@tokenizer.identifier} </identifier>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    if [:STATIC, :FIELD].include?(@tokenizer.key_word)
      compile_class_var_dec
    elsif [:CONSTRUCTOR, :FUNCTION, :METHOD, :VOID].include?(@tokenizer.key_word)
      compile_subroutine
    end

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")
    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<identifier> #{@tokenizer.identifier} </identifier>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")
    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    raise NotImplementedError
  end
end

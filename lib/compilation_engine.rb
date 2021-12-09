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
    @output.puts("<symbol> { </symbol>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    if @tokenizer.token_type == :KEYWORD
      compile_class_var_dec
    end

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<symbol> } </symbol>")
    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")
    @output.puts("<keyword> int </keyword>")
    @output.puts("<identifier> bloop </identifier>")
    @output.puts("<symbol> ; </symbol>")
    @output.puts("</classVarDec>")
  end
end

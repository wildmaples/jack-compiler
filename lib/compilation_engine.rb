class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
  end

  def compile_class
    @output.puts("<class>")
    advance
    @output.puts("<keyword> class </keyword>")

    advance
    @output.puts("<identifier> #{@tokenizer.identifier} </identifier>")

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    advance
    if [:STATIC, :FIELD].include?(@tokenizer.key_word)
      compile_class_var_dec
    elsif [:CONSTRUCTOR, :FUNCTION, :METHOD, :VOID].include?(@tokenizer.key_word)
      compile_subroutine
    end

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")
    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    advance
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    advance
    @output.puts("<identifier> #{@tokenizer.identifier} </identifier>")

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")
    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    advance
    @output.puts("<keyword> #{@tokenizer.key_word.downcase.to_s} </keyword>")

    advance
    @output.puts("<identifier> #{@tokenizer.identifier} </identifier>")

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    compile_parameter_list

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")
    @output.puts("</parameterList>")
  end

  private

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end

  def compile_subroutine_body
    @output.puts("<subroutineBody>")

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    advance
    @output.puts("<symbol> #{@tokenizer.symbol} </symbol>")

    @output.puts("</subroutineBody>")
  end
end

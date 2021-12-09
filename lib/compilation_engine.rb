class CompilationEngine
  def initialize(input, output)
    @output = output
    @tokenizer = JackTokenizer.new(input)
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
      @output.puts <<~HEREDOC
        <classVarDec>
        <keyword> field </keyword>
        <keyword> int </keyword>
        <identifier> bloop </identifier>
        <symbol> ; </symbol>
        </classVarDec>
      HEREDOC
    end

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("<symbol> } </symbol>")
    @output.puts("</class>")
  end
end

class CompilationEngine
  def initialize(input, output)
    @output = output
    @tokenizer = JackTokenizer.new(input)
  end

  def compile_class
    @output.puts("<class>")
    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("  <keyword> class </keyword>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("  <identifier> #{@tokenizer.identifier} </identifier>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("  <symbol> { </symbol>")

    @tokenizer.has_more_tokens? && @tokenizer.advance
    if @tokenizer.token_type == :KEYWORD
      @output.puts <<~HEREDOC
        \s\s<classVarDec>
        \s\s\s\s<keyword> field </keyword>
        \s\s\s\s<keyword> int </keyword>
        \s\s\s\s<identifier> bloop </identifier>
        \s\s\s\s<symbol> ; </symbol>
        \s\s</classVarDec>
      HEREDOC
    end

    @tokenizer.has_more_tokens? && @tokenizer.advance
    @output.puts("  <symbol> } </symbol>")
    @output.puts("</class>")
  end
end

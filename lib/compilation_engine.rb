class CompilationEngine
  def initialize(input, output)
    @output = output
    @tokenizer = JackTokenizer.new(input)
  end

  def compile_class
    @output.puts("<class>")
    @tokenizer.has_more_tokens?
    @tokenizer.advance
    @output.puts("  <keyword> class </keyword>")

    @tokenizer.has_more_tokens?
    @tokenizer.advance
    @output.puts("  <identifier> #{@tokenizer.identifier} </identifier>")

    @output.puts <<~HEREDOC
        <symbol> { </symbol>
        <symbol> } </symbol>
      </class>
    HEREDOC
  end
end

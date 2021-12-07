class CompilationEngine
  def initialize(input, output)
    @output = output
  end

  def compile_class
    @output.puts <<~HEREDOC
      <class>
        <keyword> class </keyword>
        <identifier> Foo </identifier>
        <symbol> { </symbol>
        <symbol> } </symbol>
      </class>
    HEREDOC
  end
end

require "test_helper"
require "compilation_engine"

class CompilationEngineTest < Minitest::Test
  def test_compile_class_compiles_empty_class
    input = StringIO.new("class Foo { }")
    output = StringIO.new
    compilation_engine = CompilationEngine.new(input, output)
    compilation_engine.compile_class

    expected = <<~HEREDOC
      <class>
        <keyword> class </keyword>
        <identifier> Foo </identifier>
        <symbol> { </symbol>
        <symbol> } </symbol>
      </class>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_class_compiles_another_empty_class
    input = StringIO.new("class Bar { }")
    output = StringIO.new
    compilation_engine = CompilationEngine.new(input, output)
    compilation_engine.compile_class

    expected = <<~HEREDOC
      <class>
        <keyword> class </keyword>
        <identifier> Bar </identifier>
        <symbol> { </symbol>
        <symbol> } </symbol>
      </class>
    HEREDOC

    assert_equal(expected, output.string)
  end
end

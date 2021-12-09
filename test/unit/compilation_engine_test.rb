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

  def test_compile_class_compiles_class_with_class_var_dec
    input = StringIO.new("class Foo { field int bloop; }")
    output = StringIO.new
    compilation_engine = CompilationEngine.new(input, output)
    compilation_engine.compile_class

    expected = <<~HEREDOC
      <class>
      <keyword> class </keyword>
      <identifier> Foo </identifier>
      <symbol> { </symbol>
      <classVarDec>
      <keyword> field </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </classVarDec>
      <symbol> } </symbol>
      </class>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_class_var_dec_for_field_variables
    input = StringIO.new("field int bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_class_var_dec

    expected = <<~HEREDOC
      <classVarDec>
      <keyword> field </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </classVarDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_class_var_dec_for_static_variables
    input = StringIO.new("static int bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_class_var_dec

    expected = <<~HEREDOC
      <classVarDec>
      <keyword> static </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </classVarDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_class_var_dec_for_different_variable_type
    input = StringIO.new("static boolean bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_class_var_dec

    expected = <<~HEREDOC
      <classVarDec>
      <keyword> static </keyword>
      <keyword> boolean </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </classVarDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_class_var_dec_for_different_variable_name
    input = StringIO.new("static boolean bleep;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_class_var_dec

    expected = <<~HEREDOC
      <classVarDec>
      <keyword> static </keyword>
      <keyword> boolean </keyword>
      <identifier> bleep </identifier>
      <symbol> ; </symbol>
      </classVarDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_subroutine_empty_method
    input = StringIO.new("method void foo() { }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_subroutine

    expected = <<~HEREDOC
      <subroutineDec>
      <keyword> method </keyword>
      <keyword> void </keyword>
      <identifier> foo </identifier>
      <symbol> ( </symbol>
      <parameterList>
      </parameterList>
      <symbol> ) </symbol>
      <subroutineBody>
      <symbol> { </symbol>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
    HEREDOC

    assert_equal(expected, output.string)
  end
end

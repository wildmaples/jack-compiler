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

  def test_compile_subroutine_with_parameters
    input = StringIO.new("method void foo(int bloop) { }")
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
      <keyword> int </keyword>
      <identifier> bloop </identifier>
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

  def test_compile_parameter_list
    input = StringIO.new("(int bloop, char bleep)")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_parameter_list

    expected = <<~HEREDOC
      <parameterList>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> , </symbol>
      <keyword> char </keyword>
      <identifier> bleep </identifier>
      </parameterList>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_var_dec_one_variable
    input = StringIO.new("var int bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance

    assert tokenizer.token_type, :KEY_WORD
    assert tokenizer.key_word, "var"

    compilation_engine.compile_var_dec

    expected = <<~HEREDOC
      <varDec>
      <keyword> var </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </varDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_var_dec_multiple_variables
    input = StringIO.new("var int bloop, bleep, bluup;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_var_dec

    expected = <<~HEREDOC
      <varDec>
      <keyword> var </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> , </symbol>
      <identifier> bleep </identifier>
      <symbol> , </symbol>
      <identifier> bluup </identifier>
      <symbol> ; </symbol>
      </varDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_subroutine_with_variable_declaration
    input = StringIO.new("method void foo() { var int bloop; }")
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
      <varDec>
      <keyword> var </keyword>
      <keyword> int </keyword>
      <identifier> bloop </identifier>
      <symbol> ; </symbol>
      </varDec>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_return_returns_void
    input = StringIO.new("return;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_return

    expected = <<~HEREDOC
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_statements_with_only_return
    input = StringIO.new("return; return;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_statements

    expected = <<~HEREDOC
      <statements>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
    HEREDOC

    assert_equal(expected, output.string)
  end
end

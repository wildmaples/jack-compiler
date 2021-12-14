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

  def test_compile_class_compiles_class_var_dec_and_subroutines
    input = StringIO.new("class Foo { field int bloop; method void foo() { } }")
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
      <statements>
      </statements>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
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

  def test_compile_class_var_dec_for_multiple_variables
    input = StringIO.new("static boolean bleep, bloop, bluup;")
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
      <symbol> , </symbol>
      <identifier> bloop </identifier>
      <symbol> , </symbol>
      <identifier> bluup </identifier>
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
      <statements>
      </statements>
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
      <statements>
      </statements>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_parameter_list
    input = StringIO.new("int bloop, char bleep")
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
      <statements>
      </statements>
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

  def test_compile_statements_with_let_return_while_if_and_do
    statements = <<~HEREDOC
      while (true) { }
      if (false) { } else { }
      let bloop = bloop;
      do bloop();
      return;
    HEREDOC
    input = StringIO.new(statements)
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_statements

    expected = <<~HEREDOC
      <statements>
      <whileStatement>
      <keyword> while </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      </whileStatement>
      <ifStatement>
      <keyword> if </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> false </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      <keyword> else </keyword>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      </ifStatement>
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
      <doStatement>
      <keyword> do </keyword>
      <identifier> bloop </identifier>
      <symbol> ( </symbol>
      <expressionList>
      </expressionList>
      <symbol> ) </symbol>
      <symbol> ; </symbol>
      </doStatement>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_return_returns_expression
    input = StringIO.new("return bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_return

    expected = <<~HEREDOC
      <returnStatement>
      <keyword> return </keyword>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </returnStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_let_compiles_simple_let_statement
    input = StringIO.new("let bloop = bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_let

    expected = <<~HEREDOC
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_let_compiles_let_statement_with_expression
    input = StringIO.new("let bloop[1] = bloop;")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_let

    expected = <<~HEREDOC
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> [ </symbol>
      <expression>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      </expression>
      <symbol> ] </symbol>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_while_simple_loop
    input = StringIO.new("while (true) { }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_while

    expected = <<~HEREDOC
      <whileStatement>
      <keyword> while </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      </whileStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_while_with_statements
    input = StringIO.new("while (true) { let bloop = bloop; return; }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_while

    expected = <<~HEREDOC
      <whileStatement>
      <keyword> while </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
      <symbol> } </symbol>
      </whileStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_if_with_statements
    input = StringIO.new("if (true) { let bloop = bloop; return; }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_if

    expected = <<~HEREDOC
      <ifStatement>
      <keyword> if </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
      <symbol> } </symbol>
      </ifStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_if_with_empty_else
    input = StringIO.new("if (true) { } else { }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_if

    expected = <<~HEREDOC
      <ifStatement>
      <keyword> if </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      <keyword> else </keyword>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      </ifStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_if_with_else_statements
    input = StringIO.new("if (true) { } else { let bloop = bloop; return; }")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_if

    expected = <<~HEREDOC
      <ifStatement>
      <keyword> if </keyword>
      <symbol> ( </symbol>
      <expression>
      <term>
      <keyword> true </keyword>
      </term>
      </expression>
      <symbol> ) </symbol>
      <symbol> { </symbol>
      <statements>
      </statements>
      <symbol> } </symbol>
      <keyword> else </keyword>
      <symbol> { </symbol>
      <statements>
      <letStatement>
      <keyword> let </keyword>
      <identifier> bloop </identifier>
      <symbol> = </symbol>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> ; </symbol>
      </letStatement>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
      <symbol> } </symbol>
      </ifStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_subroutine_with_variable_declaration_and_statements
    input = StringIO.new("method void foo() { var int bloop; return; }")
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
      <statements>
      <returnStatement>
      <keyword> return </keyword>
      <symbol> ; </symbol>
      </returnStatement>
      </statements>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_expression_list_single_expression
    input = StringIO.new("bloop")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_expression_list

    expected = <<~HEREDOC
      <expressionList>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      </expressionList>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_expression_list_multiple_expressions
    input = StringIO.new("bloop, \"bloop\"")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_expression_list

    expected = <<~HEREDOC
      <expressionList>
      <expression>
      <term>
      <identifier> bloop </identifier>
      </term>
      </expression>
      <symbol> , </symbol>
      <expression>
      <term>
      <stringConstant> bloop </stringConstant>
      </term>
      </expression>
      </expressionList>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_do_simple_subroutine
    input = StringIO.new("do bloop();")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_do

    expected = <<~HEREDOC
      <doStatement>
      <keyword> do </keyword>
      <identifier> bloop </identifier>
      <symbol> ( </symbol>
      <expressionList>
      </expressionList>
      <symbol> ) </symbol>
      <symbol> ; </symbol>
      </doStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_do_simple_chained_subroutine
    input = StringIO.new("do bloop.send();")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_do

    expected = <<~HEREDOC
      <doStatement>
      <keyword> do </keyword>
      <identifier> bloop </identifier>
      <symbol> . </symbol>
      <identifier> send </identifier>
      <symbol> ( </symbol>
      <expressionList>
      </expressionList>
      <symbol> ) </symbol>
      <symbol> ; </symbol>
      </doStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_do_with_arguments
    input = StringIO.new("do bloop(1, 2);")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_do

    expected = <<~HEREDOC
      <doStatement>
      <keyword> do </keyword>
      <identifier> bloop </identifier>
      <symbol> ( </symbol>
      <expressionList>
      <expression>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      </expression>
      <symbol> , </symbol>
      <expression>
      <term>
      <integerConstant> 2 </integerConstant>
      </term>
      </expression>
      </expressionList>
      <symbol> ) </symbol>
      <symbol> ; </symbol>
      </doStatement>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_subroutine_with_multiple_variable_declaration
    input = StringIO.new("method void foo() { var int bloop; var boolean bleep; }")
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
      <varDec>
      <keyword> var </keyword>
      <keyword> boolean </keyword>
      <identifier> bleep </identifier>
      <symbol> ; </symbol>
      </varDec>
      <statements>
      </statements>
      <symbol> } </symbol>
      </subroutineBody>
      </subroutineDec>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_term_identifier
    input = StringIO.new("foo")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_term

    expected = <<~HEREDOC
      <term>
      <identifier> foo </identifier>
      </term>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_term_unary_op
    input = StringIO.new("-1")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_term

    expected = <<~HEREDOC
      <term>
      <symbol> - </symbol>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      </term>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_term_array_index
    input = StringIO.new("bloop[99]")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_term

    expected = <<~HEREDOC
      <term>
      <identifier> bloop </identifier>
      <symbol> [ </symbol>
      <expression>
      <term>
      <integerConstant> 99 </integerConstant>
      </term>
      </expression>
      <symbol> ] </symbol>
      </term>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_term_expression
    input = StringIO.new("(0)")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_term

    expected = <<~HEREDOC
      <term>
      <symbol> ( </symbol>
      <expression>
      <term>
      <integerConstant> 0 </integerConstant>
      </term>
      </expression>
      <symbol> ) </symbol>
      </term>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_term_subroutine_call
    input = StringIO.new("bloop()")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_term

    expected = <<~HEREDOC
      <term>
      <identifier> bloop </identifier>
      <symbol> ( </symbol>
      <expressionList>
      </expressionList>
      <symbol> ) </symbol>
      </term>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_expression_of_single_term
    input = StringIO.new("foo")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_expression

    expected = <<~HEREDOC
      <expression>
      <term>
      <identifier> foo </identifier>
      </term>
      </expression>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_expression_of_terms_with_operation
    input = StringIO.new("1 + 1")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_expression

    expected = <<~HEREDOC
      <expression>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      <symbol> + </symbol>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      </expression>
    HEREDOC

    assert_equal(expected, output.string)
  end

  def test_compile_expression_of_terms_with_multiple_operations
    input = StringIO.new("1 + 2 - 3")
    output = StringIO.new
    tokenizer = JackTokenizer.new(input)
    compilation_engine = CompilationEngine.new(input, output, tokenizer: tokenizer)

    assert tokenizer.has_more_tokens?
    tokenizer.advance
    compilation_engine.compile_expression

    expected = <<~HEREDOC
      <expression>
      <term>
      <integerConstant> 1 </integerConstant>
      </term>
      <symbol> + </symbol>
      <term>
      <integerConstant> 2 </integerConstant>
      </term>
      <symbol> - </symbol>
      <term>
      <integerConstant> 3 </integerConstant>
      </term>
      </expression>
    HEREDOC

    assert_equal(expected, output.string)
  end
end

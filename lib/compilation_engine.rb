require 'cgi'
require_relative 'jack_tokenizer'

class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
  end

  attr_reader :tokenizer

  def compile_class
    @output.puts("<class>")
    advance

    output_token # class
    output_token # className
    output_token # {

    until symbol_token?("}")
      case @tokenizer.key_word
      when :STATIC, :FIELD
        compile_class_var_dec
      when :CONSTRUCTOR, :FUNCTION, :METHOD, :VOID
        compile_subroutine
      end
    end

    output_token # }

    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")

    output_token # static / field
    output_token # type
    output_token # varName

    while symbol_token?(",")
      output_token # ,
      output_token # varName
    end

    output_token # ;

    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    output_token # constructor / function / method
    output_token # void / type
    output_token # subroutineName
    output_token # (

    compile_parameter_list

    output_token # )

    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")

    unless symbol_token?(")")
      output_token # type
      output_token # varName

      while symbol_token?(",")
        output_token # ,
        output_token # type
        output_token # varName
      end
    end

    @output.puts("</parameterList>")
  end

  def compile_var_dec
    @output.puts("<varDec>")
    output_token # var
    output_token # type
    output_token # varName

    while symbol_token?(",")
      output_token # ,
      output_token # varName
    end

    output_token # ;

    @output.puts("</varDec>")
  end

  def compile_statements
    @output.puts("<statements>")

    while keyword_token?
      case @tokenizer.key_word
      when :RETURN
        compile_return
      when :LET
        compile_let
      when :WHILE
        compile_while
      when :IF
        compile_if
      when :DO
        compile_do
      end
    end

    @output.puts("</statements>")
  end

  def compile_return
    @output.puts("<returnStatement>")

    output_token # return

    unless symbol_token?(";")
      compile_expression
    end

    output_token # ;

    @output.puts("</returnStatement>")
  end

  def compile_let
    @output.puts("<letStatement>")
    output_token # let
    output_token # varName

    if symbol_token?("[")
      output_token # [
      compile_expression
      output_token # ]
    end

    output_token # =

    compile_expression # expression

    output_token # ;
    @output.puts("</letStatement>")
  end

  def compile_while
    @output.puts("<whileStatement>")
    output_token # while

    output_token # (
    compile_expression
    output_token # )

    output_token # {
    compile_statements
    output_token # }
    @output.puts("</whileStatement>")
  end

  def compile_if
    @output.puts("<ifStatement>")
    output_token # if

    output_token # (
    compile_expression
    output_token # )

    output_token # {
    compile_statements
    output_token # }

    if keyword_token?(:ELSE)
      output_token # else
      output_token # {
      compile_statements
      output_token # }
    end

    @output.puts("</ifStatement>")
  end

  OP_SYMBOLS = %w[+ - * / & | < > =]

  def compile_expression
    @output.puts("<expression>")
    compile_term

    while symbol_token?(*OP_SYMBOLS)
      output_token # op symbol
      compile_term
    end

    @output.puts("</expression>")
  end

  def compile_expression_list
    @output.puts("<expressionList>")

    unless symbol_token?(")")
      compile_expression

      while symbol_token?(",")
        output_token # ,
        compile_expression
      end
    end

    @output.puts("</expressionList>")
  end

  def compile_do
    @output.puts("<doStatement>")
    output_token # do
    compile_subroutine_call
    @output.puts("</doStatement>")
  end

  def compile_term
    @output.puts("<term>")

    if symbol_token?(*["-", "~"])
      output_token # unary op
      compile_term
    else
      output_token # int / str / keyword / identifier / subroutine call / expression

      if symbol_token?("[")
        output_token # [
        compile_expression
        output_token # ]
      end
    end

    @output.puts("</term>")
  end

  private

  def compile_subroutine_body
    @output.puts("<subroutineBody>")

    output_token # {

    while keyword_token?(:VAR)
      compile_var_dec
    end

    compile_statements

    output_token # }

    @output.puts("</subroutineBody>")
  end

  def compile_subroutine_call
    output_token # subroutineName

    if symbol_token?(".")
      output_token # .
      output_token # subroutineName
    end

    output_token # (
    compile_expression_list
    output_token # )
    output_token # ;
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end

  def output_token
    case tokenizer.token_type
    when :STRING_CONST
      token = tokenizer.string_val
      token_type = "stringConstant"
    when :INT_CONST
      token = tokenizer.int_val.to_s
      token_type = "integerConstant"
    when :KEYWORD
      token = tokenizer.key_word.downcase.to_s
      token_type = "keyword"
    when :IDENTIFIER
      token = tokenizer.identifier
      token_type = "identifier"
    when :SYMBOL
      token = tokenizer.symbol
      token_type = "symbol"
    end

    @output.puts("<#{token_type}> #{CGI.escapeHTML(token)} </#{token_type}>")
    advance
  end

  def symbol_token?(*symbols)
    @tokenizer.token_type == :SYMBOL && symbols.include?(@tokenizer.symbol)
  end

  def keyword_token?(keyword = nil)
    if keyword.nil?
      @tokenizer.token_type == :KEYWORD
    else
      @tokenizer.token_type == :KEYWORD && @tokenizer.key_word == keyword
    end
  end
end

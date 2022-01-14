require 'cgi'
require_relative 'jack_tokenizer'
require_relative 'symbol_table'
require_relative 'vm_writer'

class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
    @symbol_table = SymbolTable.new
    @vm_writer = VMWriter.new(output)
  end

  attr_reader :tokenizer

  def compile_class
    @output.puts("<class>")
    advance

    output_token # class

    @class_name = @tokenizer.identifier
    output_token # className

    @output.puts("(class, defined, false, nil)")

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

    kind = @tokenizer.key_word
    output_token # static / field

    type = @tokenizer.key_word
    output_token # type

    name = @tokenizer.identifier
    output_token # varName

    @symbol_table.define(name, type, kind)
    @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")

    while symbol_token?(",")
      output_token # ,

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)
      @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")
    end

    output_token # ;

    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    @symbol_table.start_subroutine

    kind = @tokenizer.key_word
    output_token # constructor / function / method

    @subroutine_type = type = @tokenizer.key_word
    output_token # void / type

    name = @tokenizer.identifier
    output_token # subroutineName

    @output.puts("(#{kind}, defined, false, nil)")
    output_token # (

    compile_parameter_list

    output_token # )

    full_subroutine_name = "#{@class_name}.#{name}"
    @vm_writer.write_function(full_subroutine_name, @symbol_table.var_count(name))

    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")

    unless symbol_token?(")")
      kind = :ARG
      type = @tokenizer.key_word
      output_token # type

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)
      @output.puts("(#{@symbol_table.kind_of(name)}, used, true, #{@symbol_table.index_of(name)})")

      while symbol_token?(",")
        output_token # ,

        type = @tokenizer.key_word
        output_token # type

        name = @tokenizer.identifier
        output_token # varName

        @symbol_table.define(name, type, kind)
        @output.puts("(#{@symbol_table.kind_of(name)}, used, true, #{@symbol_table.index_of(name)})")
      end
    end

    @output.puts("</parameterList>")
  end

  def compile_var_dec
    @output.puts("<varDec>")

    kind = @tokenizer.key_word
    output_token # var

    type = @tokenizer.key_word
    output_token # type

    name = @tokenizer.identifier
    output_token # varName

    @symbol_table.define(name, type, kind)
    @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")

    while symbol_token?(",")
      output_token # ,

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)
      @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")
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
      operator_symbol = @tokenizer.symbol
      output_token # op symbol
      compile_term
    end

    write_operator(operator_symbol)

    @output.puts("</expression>")
  end

  def compile_expression_list
    @output.puts("<expressionList>")

    @expressions_count = 0
    unless symbol_token?(")")
      compile_expression
      @expressions_count += 1

      while symbol_token?(",")
        output_token # ,
        compile_expression
        @expressions_count += 1
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

    if symbol_token?("-", "~")
      output_token # unary op
      compile_term

    elsif symbol_token?("(")
      output_token # (
      compile_expression
      output_token # )

    else
      name = @tokenizer.identifier
      if @tokenizer.token_type == :IDENTIFIER
        @output.puts("(#{@symbol_table.kind_of(name)}, used, true, #{@symbol_table.index_of(name)})")
      end

      output_token # int / str / keyword / identifier / start of a subroutine call
      if symbol_token?("[")
        output_token # [
        compile_expression
        output_token # ]

      elsif symbol_token?("(")
        output_token # (
        compile_expression_list
        output_token # )

      elsif symbol_token?(".")
        output_token # .
        output_token # subroutineName
        output_token # (
        compile_expression_list
        output_token # )
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
    class_name = @tokenizer.identifier
    output_token # subroutineName

    @output.puts("(subroutine, nil, false, nil)")

    if symbol_token?(".")
      output_token # .
      subroutine_name = @tokenizer.identifier
      output_token # subroutineName
      @output.puts("(subroutine, nil, false, nil)")
    end

    output_token # (
    compile_expression_list
    output_token # )
    output_token # ;

    @vm_writer.write_call("#{class_name}.#{subroutine_name}", @expressions_count)
    @vm_writer.write_pop(:TEMP, 0)
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
      @vm_writer.write_push(:CONST, tokenizer.int_val)
    when :KEYWORD
      token = tokenizer.key_word.downcase.to_s
      token_type = "keyword"
      case token
      when "return"
        if @subroutine_type == :VOID
          @vm_writer.write_push(:CONST, 0)
          @vm_writer.write_return
        end
      end
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

  def write_operator(symbol)
    case symbol
    when "*"
      @vm_writer.write_call("Math.multiply", 2)
    when "+"
      @vm_writer.write_arithmetic(:ADD)
    end
  end
end

require 'cgi'
require_relative 'jack_tokenizer'
require_relative 'symbol_table'
require_relative 'vm_writer'
require_relative 'expression_parser'

class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
    @symbol_table = SymbolTable.new
    @vm_writer = VMWriter.new(output)
    @expression_parser = ExpressionParser.new(@tokenizer, @symbol_table)
  end

  attr_reader :tokenizer

  def compile_class
    advance
    advance # class

    @class_name = @tokenizer.identifier
    advance # className

    advance # {

    until symbol_token?("}")
      case @tokenizer.key_word
      when :STATIC, :FIELD
        compile_class_var_dec
      when :CONSTRUCTOR, :FUNCTION, :METHOD, :VOID
        compile_subroutine
      end
    end

    advance # }
  end

  def compile_class_var_dec
    kind = @tokenizer.key_word
    advance # static / field

    type = @tokenizer.key_word
    advance # type

    name = @tokenizer.identifier
    advance # varName

    @symbol_table.define(name, type, kind)

    while symbol_token?(",")
      advance # ,

      name = @tokenizer.identifier
      advance # varName

      @symbol_table.define(name, type, kind)
      @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")
    end

    advance # ;
  end

  def compile_subroutine
    @symbol_table.start_subroutine

    _kind = @tokenizer.key_word
    advance # constructor / function / method

    @subroutine_type = type = @tokenizer.key_word
    advance # void / type

    @subroutine_name = @tokenizer.identifier
    advance # subroutineName

    advance # (
    compile_parameter_list
    advance # )

    compile_subroutine_body
  end

  def compile_parameter_list

    unless symbol_token?(")")
      kind = :ARG
      type = @tokenizer.key_word
      advance # type

      name = @tokenizer.identifier
      advance # varName

      @symbol_table.define(name, type, kind)

      while symbol_token?(",")
        advance # ,

        type = @tokenizer.key_word
        advance # type

        name = @tokenizer.identifier
        advance # varName

        @symbol_table.define(name, type, kind)
      end
    end
  end

  def compile_var_dec
    kind = @tokenizer.key_word
    advance # var

    type = @tokenizer.key_word
    advance # type

    name = @tokenizer.identifier
    advance # varName

    @symbol_table.define(name, type, kind)

    while symbol_token?(",")
      advance # ,

      name = @tokenizer.identifier
      advance # varName

      @symbol_table.define(name, type, kind)
    end

    advance # ;
  end

  def compile_statements
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
  end

  def compile_return
    @vm_writer.write_push(:CONST, 0)
    @vm_writer.write_return
    advance

    unless symbol_token?(";")
      compile_expression
    end

    advance # ;
  end

  def compile_let
    advance # let

    variable_name = @tokenizer.identifier
    advance # varName

    if symbol_token?("[")
      advance # [
      compile_expression
      advance # ]
    end

    advance # =

    compile_expression # expression
    @vm_writer.write_pop(:LOCAL, @symbol_table.index_of(variable_name))

    advance # ;
  end

  def compile_while
    advance # while

    advance # (
    compile_expression
    advance # )

    advance # {
    compile_statements
    advance # }
  end

  def compile_if
    advance # if

    advance # (
    compile_expression
    advance # )

    advance # {
    compile_statements
    advance # }

    if keyword_token?(:ELSE)
      advance # else
      advance # {
      compile_statements
      advance # }
    end
  end

  def compile_expression
    ast = @expression_parser.parse_expression
    ast.write_vm_code(@vm_writer)
  end

  def compile_expression_list
    @expressions_count = 0
    unless symbol_token?(")")
      compile_expression
      @expressions_count += 1

      while symbol_token?(",")
        advance # ,
        compile_expression
        @expressions_count += 1
      end
    end
  end

  def compile_do
    advance # do
    compile_subroutine_call
  end

  def compile_term
    if symbol_token?("-", "~")
      unary_op = @tokenizer.symbol
      advance # unary op
      compile_term
      @vm_writer.write_arithmetic(:NEG) if unary_op == "-"

    elsif symbol_token?("(")
      advance # (
      compile_expression
      advance # )

    else
      name = @tokenizer.identifier

      if @symbol_table.kind_of(name) == :VAR
        @vm_writer.write_push(:LOCAL, @symbol_table.index_of(name))
      end

      advance # int / str / keyword / identifier / start of a subroutine call

      if symbol_token?("[")
        advance # [
        compile_expression
        advance # ]

      elsif symbol_token?("(")
        advance # (
        compile_expression_list
        advance # )

      elsif symbol_token?(".")
        advance # .

        subroutine_name = @tokenizer.identifier
        advance # subroutineName

        advance # (
        compile_expression_list
        advance # )

        @vm_writer.write_call("#{name}.#{subroutine_name}", @expressions_count)
      end
    end
  end

  private

  def compile_subroutine_body
    advance # {

    while keyword_token?(:VAR)
      compile_var_dec
    end

    @vm_writer.write_function("#{@class_name}.#{@subroutine_name}", @symbol_table.var_count(:VAR))

    compile_statements

    advance # }
  end

  def compile_subroutine_call
    @expression_parser.parse_term.write_vm_code(@vm_writer)
    advance # ;
    @vm_writer.write_pop(:TEMP, 0)
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
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

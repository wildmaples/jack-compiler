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
    @expression_parser = ExpressionParser.new(@tokenizer)
  end

  attr_reader :tokenizer

  def compile_class
    advance
    output_token # class

    @class_name = @tokenizer.identifier
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
  end

  def compile_class_var_dec
    kind = @tokenizer.key_word
    output_token # static / field

    type = @tokenizer.key_word
    output_token # type

    name = @tokenizer.identifier
    output_token # varName

    @symbol_table.define(name, type, kind)

    while symbol_token?(",")
      output_token # ,

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)
      @output.puts("(#{@symbol_table.kind_of(name)}, defined, true, #{@symbol_table.index_of(name)})")
    end

    output_token # ;
  end

  def compile_subroutine
    @symbol_table.start_subroutine

    _kind = @tokenizer.key_word
    output_token # constructor / function / method

    @subroutine_type = type = @tokenizer.key_word
    output_token # void / type

    @subroutine_name = @tokenizer.identifier
    output_token # subroutineName

    output_token # (
    compile_parameter_list
    output_token # )

    compile_subroutine_body
  end

  def compile_parameter_list

    unless symbol_token?(")")
      kind = :ARG
      type = @tokenizer.key_word
      output_token # type

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)

      while symbol_token?(",")
        output_token # ,

        type = @tokenizer.key_word
        output_token # type

        name = @tokenizer.identifier
        output_token # varName

        @symbol_table.define(name, type, kind)
      end
    end
  end

  def compile_var_dec
    kind = @tokenizer.key_word
    output_token # var

    type = @tokenizer.key_word
    output_token # type

    name = @tokenizer.identifier
    output_token # varName

    @symbol_table.define(name, type, kind)

    while symbol_token?(",")
      output_token # ,

      name = @tokenizer.identifier
      output_token # varName

      @symbol_table.define(name, type, kind)
    end

    output_token # ;
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
    output_token # return

    unless symbol_token?(";")
      compile_expression
    end

    output_token # ;
  end

  def compile_let
    output_token # let

    variable_name = @tokenizer.identifier
    output_token # varName

    if symbol_token?("[")
      output_token # [
      compile_expression
      output_token # ]
    end

    output_token # =

    compile_expression # expression
    @vm_writer.write_pop(:LOCAL, @symbol_table.index_of(variable_name))

    output_token # ;
  end

  def compile_while
    output_token # while

    output_token # (
    compile_expression
    output_token # )

    output_token # {
    compile_statements
    output_token # }
  end

  def compile_if
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
        output_token # ,
        compile_expression
        @expressions_count += 1
      end
    end
  end

  def compile_do
    output_token # do
    compile_subroutine_call
  end

  def compile_term
    if symbol_token?("-", "~")
      unary_op = @tokenizer.symbol
      output_token # unary op
      compile_term
      @vm_writer.write_arithmetic(:NEG) if unary_op == "-"

    elsif symbol_token?("(")
      output_token # (
      compile_expression
      output_token # )

    else
      name = @tokenizer.identifier

      if @symbol_table.kind_of(name) == :VAR
        @vm_writer.write_push(:LOCAL, @symbol_table.index_of(name))
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

        subroutine_name = @tokenizer.identifier
        output_token # subroutineName

        output_token # (
        compile_expression_list
        output_token # )

        @vm_writer.write_call("#{name}.#{subroutine_name}", @expressions_count)
      end
    end
  end

  private

  def compile_subroutine_body
    output_token # {

    while keyword_token?(:VAR)
      compile_var_dec
    end

    @vm_writer.write_function("#{@class_name}.#{@subroutine_name}", @symbol_table.var_count(:VAR))

    compile_statements

    output_token # }
  end

  def compile_subroutine_call
    @expression_parser.parse_term.write_vm_code(@vm_writer)
    advance # ;
    @vm_writer.write_pop(:TEMP, 0)
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end

  def output_token
    case tokenizer.token_type
    when :INT_CONST
      @vm_writer.write_push(:CONST, tokenizer.int_val)
    when :KEYWORD
      token = tokenizer.key_word.downcase.to_s
      case token
      when "return"
        if @subroutine_type == :VOID
          @vm_writer.write_push(:CONST, 0)
          @vm_writer.write_return
        end
      end
    end

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

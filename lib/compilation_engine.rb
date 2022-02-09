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

    @while_count = 0
    @if_count = 0
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

    type = keyword_or_identifier
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

  def compile_subroutine
    @symbol_table.start_subroutine

    kind = @tokenizer.key_word
    advance # constructor / function / method

    @subroutine_type = type = keyword_or_identifier
    advance # void / type

    subroutine_name = @tokenizer.identifier
    advance # subroutineName

    advance # (
    compile_parameter_list
    advance # )

    advance # {

    while keyword_token?(:VAR)
      compile_var_dec
    end

    local_var = @symbol_table.var_count(:VAR)
    local_var += 1 if kind == :METHOD

    @vm_writer.write_function("#{@class_name}.#{subroutine_name}", local_var)

    if kind == :CONSTRUCTOR
      @vm_writer.write_push(:CONST, @symbol_table.var_count(:FIELD))
      @vm_writer.write_call("Memory.alloc", 1)
      @vm_writer.write_pop(:POINTER, 0)
    elsif kind == :METHOD
      @vm_writer.write_push(:ARG, 0)
      @vm_writer.write_pop(:POINTER, 0)
    end

    compile_statements
    advance # }
  end

  def compile_parameter_list

    unless symbol_token?(")")
      kind = :ARG
      type = keyword_or_identifier
      advance # type

      name = @tokenizer.identifier
      advance # varName

      @symbol_table.define(name, type, kind)

      while symbol_token?(",")
        advance # ,

        type = keyword_or_identifier
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

    type = keyword_or_identifier
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
    advance

    if symbol_token?(";")
      @vm_writer.write_push(:CONST, 0)
    elsif keyword_token?(:THIS)
      @vm_writer.write_push(:POINTER, 0)
      advance
    else
      compile_expression
    end

    @vm_writer.write_return
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

    kind = @symbol_table.kind_of(variable_name)
    @vm_writer.write_pop(kind_to_segment(kind), @symbol_table.index_of(variable_name))

    advance # ;
  end

  def compile_while
    while_count = @while_count
    @while_count += 1

    advance # while
    @vm_writer.write_label("WHILE_COND#{while_count}")

    advance # (
    compile_expression
    advance # )

    @vm_writer.write_if("WHILE_TRUE#{while_count}")
    @vm_writer.write_goto("WHILE_END#{while_count}")
    @vm_writer.write_label("WHILE_TRUE#{while_count}")

    advance # {
    compile_statements
    advance # }

    @vm_writer.write_goto("WHILE_COND#{while_count}")
    @vm_writer.write_label("WHILE_END#{while_count}")
  end

  def compile_if
    if_count = @if_count
    @if_count += 1
    advance # if

    advance # (
    compile_expression
    advance # )

    @vm_writer.write_if("IF_TRUE#{if_count}")
    @vm_writer.write_goto("IF_FALSE#{if_count}")
    @vm_writer.write_label("IF_TRUE#{if_count}")
    advance # {
    compile_statements
    advance # }

    if keyword_token?(:ELSE)
      @vm_writer.write_goto("IF_END#{if_count}")
      @vm_writer.write_label("IF_FALSE#{if_count}")
      advance # else
      advance # {
      compile_statements
      advance # }
    end

    @vm_writer.write_label("IF_END#{if_count}")
  end

  def compile_expression
    ast = @expression_parser.parse_expression
    ast.write_vm_code(@vm_writer, @symbol_table)
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
    ast = @expression_parser.parse_term(@class_name)
    ast.write_vm_code(@vm_writer, @symbol_table)
    advance # ;
    @vm_writer.write_pop(:TEMP, 0)
  end

  private

  def kind_to_segment(kind)
    case kind
    when :VAR
      :LOCAL
    when :FIELD
      :THIS
    else
      kind
    end
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

  def keyword_or_identifier
    case @tokenizer.token_type
    when :KEY_WORD
      @tokenizer.keyword
    when :IDENTIFIER
      @tokenizer.identifier
    end
  end
end

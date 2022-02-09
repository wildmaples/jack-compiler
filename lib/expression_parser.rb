ArithmeticOp = Struct.new(:operator, :left, :right) do
  def write_vm_code(vm_writer, symbol_table)
    left.write_vm_code(vm_writer, symbol_table)
    right.write_vm_code(vm_writer, symbol_table)

    case operator
    when "+"
      vm_writer.write_arithmetic(:ADD)
    when "*"
      vm_writer.write_call("Math.multiply", 2)
    when ">"
      vm_writer.write_arithmetic(:GT)
    when "="
      vm_writer.write_arithmetic(:EQ)
    when "&"
      vm_writer.write_arithmetic(:AND)
    when "-"
      vm_writer.write_arithmetic(:SUB)
    end
  end
end

Number = Struct.new(:value) do
  def write_vm_code(vm_writer, symbol_table)
    vm_writer.write_push(:CONST, value)
  end
end

Boolean = Struct.new(:value) do
  def write_vm_code(vm_writer, symbol_table)
    vm_writer.write_push(:CONST, 0)
    vm_writer.write_arithmetic(:NOT) if value == :TRUE
  end
end

UnaryOp = Struct.new(:operator, :operand) do
  def write_vm_code(vm_writer, symbol_table)
    operand.write_vm_code(vm_writer, symbol_table)
    case operator
    when "-"
      vm_writer.write_arithmetic(:NEG)
    when "~"
      vm_writer.write_arithmetic(:NOT)
    end
  end
end

SubroutineCall = Struct.new(:type, :class_name, :subroutine_name, :expression_list) do
  def write_vm_code(vm_writer, symbol_table)
    name = class_name
    arg_length = expression_list.length

    # Push receiver
    if symbol_table.include?(name)
      name = symbol_table.type_of(class_name)
      index = symbol_table.index_of(class_name)
      kind = symbol_table.kind_of(class_name)

      vm_writer.write_push(kind == :VAR ? :LOCAL : :ARG, index)
      arg_length += 1

    # Push self
    elsif type == :METHOD
      vm_writer.write_push(:POINTER, 0)
      arg_length += 1
    end

    # Push arguments
    expression_list.each do |expression|
      expression.write_vm_code(vm_writer, symbol_table)
    end

    vm_writer.write_call("#{name}.#{subroutine_name}", arg_length)
  end
end

Variable = Struct.new(:name) do
  def write_vm_code(vm_writer, symbol_table)
    index = symbol_table.index_of(name)
    kind = symbol_table.kind_of(name)
    vm_kind = kind == :VAR ? :LOCAL : :ARG
    vm_writer.write_push(vm_kind, index)
  end
end

OP_SYMBOLS = %w[+ - * / & | < > =]

class ExpressionParser
  def initialize(tokenizer)
    @tokenizer = tokenizer
  end

  def parse_expression
    left = parse_term

    if symbol_token?(*OP_SYMBOLS)
      operator = @tokenizer.symbol
      advance
      right = parse_expression
      ArithmeticOp.new(operator, left, right)

    else
      left
    end
  end

  def parse_term(class_name = nil)
    case @tokenizer.token_type
    when :INT_CONST
      ast = Number.new(@tokenizer.int_val)
      advance

    when :KEYWORD
      keyword = @tokenizer.key_word

      if [:TRUE, :FALSE].include?(keyword)
        ast = Boolean.new(keyword)
        advance
      end

    when :SYMBOL
      symbol = @tokenizer.symbol

      if symbol_token?("-", "~")
        advance
        operand = parse_expression
        ast = UnaryOp.new(symbol, operand)

      elsif symbol_token?("(")
        advance
        ast = parse_expression
        advance
      end
    when :IDENTIFIER
      name = @tokenizer.identifier
      advance

      if symbol_token?(".")
        advance
        subroutine_name = @tokenizer.identifier
        advance

        advance
        list = parse_expression_list
        advance
        ast = SubroutineCall.new(:FUNC, name, subroutine_name, list)

      elsif symbol_token?("(")
        subroutine_name = name
        advance
        list = parse_expression_list
        advance
        ast = SubroutineCall.new(:METHOD, class_name, subroutine_name, list)

      else
        ast = Variable.new(name)
      end
    end

    ast
  end

  def parse_expression_list
    list = []

    unless symbol_token?(")")
      loop do
        list << parse_expression
        break unless symbol_token?(",")
        advance # ,
      end
    end

    list
  end

  private

  def symbol_token?(*symbols)
    @tokenizer.token_type == :SYMBOL && symbols.include?(@tokenizer.symbol)
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end
end

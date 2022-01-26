ArithmeticOp = Struct.new(:operator, :left, :right) do
  def write_vm_code(vm_writer)
    left.write_vm_code(vm_writer)
    right.write_vm_code(vm_writer)

    case operator
    when "+"
      vm_writer.write_arithmetic(:ADD)
    end
  end
end

Number = Struct.new(:value) do
  def write_vm_code(vm_writer)
    vm_writer.write_push(:CONST, value)
  end
end

UnaryOp = Struct.new(:operator, :operand) do
  def write_vm_code(vm_writer)
    operand.write_vm_code(vm_writer)
    case operator
    when "-"
      vm_writer.write_arithmetic(:NEG)
    when "~"
      vm_writer.write_arithmetic(:NOT)
    end
  end
end

SubroutineCall = Struct.new(:class_name, :subroutine_name, :expression_list) do
  def write_vm_code(vm_writer)
    expression_list.each do |expression|
      expression.write_vm_code(vm_writer)
    end
    vm_writer.write_call("#{class_name}.#{subroutine_name}", expression_list.length)
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

  def parse_term
    case @tokenizer.token_type
    when :INT_CONST
      ast = Number.new(@tokenizer.int_val)
      advance

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
        ast = SubroutineCall.new(name, subroutine_name, list)
      end
    end

    return ast
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

  def symbol_token?(*symbols)
    @tokenizer.token_type == :SYMBOL && symbols.include?(@tokenizer.symbol)
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end
end

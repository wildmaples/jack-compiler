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

OP_SYMBOLS = %w[+ - * / & | < > =]

class ExpressionParser
  def initialize(tokenizer)
    @tokenizer = tokenizer
  end

  def parse_expression
    left = parse_term

    if @tokenizer.token_type == :SYMBOL && OP_SYMBOLS.include?(@tokenizer.symbol)
      operator = @tokenizer.symbol
      @tokenizer.advance
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
      @tokenizer.advance

    when :SYMBOL
      operator = @tokenizer.symbol
      @tokenizer.advance
      operand = parse_expression
      ast = UnaryOp.new(operator, operand)
    end

    ast
  end
end

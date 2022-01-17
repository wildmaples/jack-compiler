class VMWriter
  def initialize(output)
    @output = output
  end

  def write_function(name, num_locals)
    @output.puts "function #{name} #{num_locals}"
  end

  SEGMENT_TO_VM_SYNTAX_MAP = {
    CONST: "constant",
    ARG: "argument",
    LOCAL: "local",
    STATIC: "static",
    THIS: "this",
    THAT: "that",
    POINTER: "pointer",
    TEMP: "temp"
  }

  def write_push(segment, index)
    @output.puts "push #{SEGMENT_TO_VM_SYNTAX_MAP[segment]} #{index}"
  end

  def write_pop(segment, index)
    @output.puts "pop #{SEGMENT_TO_VM_SYNTAX_MAP[segment]} #{index}"
  end

  def write_call(name, num_args)
    @output.puts "call #{name} #{num_args}"
  end

  def write_arithmetic(command)
    @output.puts "add"
  end

  def write_return
    @output.print "return"
  end
end

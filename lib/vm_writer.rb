class VMWriter
  def initialize(output)
    @output = output
  end

  def write_function(name, num_locals)
    @output.print "function #{name} #{num_locals.to_s}"
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
    @output.print "push #{SEGMENT_TO_VM_SYNTAX_MAP[segment]} #{index.to_s}"
  end

  def write_pop(segment, index)
    @output.print "pop #{SEGMENT_TO_VM_SYNTAX_MAP[segment]} #{index.to_s}"
  end

  def write_call(name, num_args)
    @output.print "call #{name} #{num_args.to_s}"
  end

  def write_arithmetic(command)
    @output.print "add"
  end
end
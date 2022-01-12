class VMWriter
  def initialize(output)
    @output = output
  end

  def write_function(name, num_locals)
    @output.print "function #{name} #{num_locals.to_s}"
  end

  def write_push(segment, index)
    segment = segment == :CONST ? "constant" : segment.downcase
    @output.print "push #{segment} #{index.to_s}"
  end
end

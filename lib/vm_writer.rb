class VMWriter
  def initialize(output)
    @output = output
  end

  def write_function(name, num_locals)
    @output.print "function #{name} #{num_locals.to_s}"
  end
end
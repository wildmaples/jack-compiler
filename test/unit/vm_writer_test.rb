require "test_helper"
require "vm_writer"

class VMWriterTest < Minitest::Test
  def setup
    @output = StringIO.new
    @vm_writer = VMWriter.new(@output)
  end

  def test_write_function
    @vm_writer.write_function("Main.foo", 3)
    assert_equal("function Main.foo 3", @output.string)
  end
end

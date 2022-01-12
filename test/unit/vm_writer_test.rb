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

  def test_write_push_constant
    @vm_writer.write_push(:CONST, 3)
    assert_equal("push constant 3", @output.string)
  end

  def test_write_push_pointer
    @vm_writer.write_push(:POINTER, 10)
    assert_equal("push pointer 10", @output.string)
  end

  def test_write_call
    @vm_writer.write_call("foo", 3)
    assert_equal("call foo 3", @output.string)
  end

  def test_write_arithmetic_add
    @vm_writer.write_arithmetic(:ADD)
    assert_equal("add", @output.string)
  end
end

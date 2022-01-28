require "test_helper"
require "vm_writer"

class VMWriterTest < Minitest::Test
  def setup
    @output = StringIO.new
    @vm_writer = VMWriter.new(@output)
  end

  def test_write_function
    @vm_writer.write_function("Main.foo", 3)
    assert_equal("function Main.foo 3\n", @output.string)
  end

  def test_write_push_constant
    @vm_writer.write_push(:CONST, 3)
    assert_equal("push constant 3\n", @output.string)
  end

  def test_write_push_pointer
    @vm_writer.write_push(:POINTER, 10)
    assert_equal("push pointer 10\n", @output.string)
  end

  def test_write_call
    @vm_writer.write_call("foo", 3)
    assert_equal("call foo 3\n", @output.string)
  end

  def test_write_arithmetic_add
    @vm_writer.write_arithmetic(:ADD)
    assert_equal("add\n", @output.string)
  end

  def test_write_pop_arguments
    @vm_writer.write_pop(:ARG, 10)
    assert_equal("pop argument 10\n", @output.string)
  end

  def test_write_label
    @vm_writer.write_label("WHILE_COND0")
    assert_equal("label WHILE_COND0\n", @output.string)
  end

  def test_write_goto
    @vm_writer.write_goto("WHILE_COND0")
    assert_equal("goto WHILE_COND0\n", @output.string)
  end

  def test_write_if
    @vm_writer.write_if("WHILE_COND0")
    assert_equal("if-goto WHILE_COND0\n", @output.string)
  end

  def test_write_return
    @vm_writer.write_return
    assert_equal("return\n", @output.string)
  end
end

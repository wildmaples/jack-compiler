require "test_helper"
require "compilation_engine"

class CompilationEngineTest < Minitest::Test
  Dir.glob("*/*.vm", base: "test/expected").each do |file_name|
    base_name = File.join(File.dirname(file_name), File.basename(file_name, ".*"))
    jack_file = File.join("examples", "#{base_name}.jack")
    vm_file_path = File.join("test/expected", "#{base_name}.vm")

    define_method("test_acceptance_#{base_name}") do
      expected_vm_code = File.open(vm_file_path)

      output = StringIO.new
      engine = CompilationEngine.new(File.open(jack_file), output)
      engine.compile_class

      assert_equal(expected_vm_code.read, output.string)
    end
  end
end

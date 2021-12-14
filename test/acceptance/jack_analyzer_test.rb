require "test_helper"
require "tempfile"

class JackAnalyzerAcceptanceTest < Minitest::Test
  TEXT_COMPARER_PATH = ENV["TEXT_COMPARER"]

  Dir.glob("ExpressionLessSquare/*.jack", base: "examples").each do |file_name|
    base_name = File.join(File.dirname(file_name), File.basename(file_name, ".*"))
    expected_xml_path = File.join("test/expected", "#{base_name}.xml")
    test_name = "test_acceptance_#{base_name}"

    define_method(test_name) do
      skip "can’t find text comparer, please set TEXT_COMPARER" unless TEXT_COMPARER_PATH

      # make a temporary file
      Tempfile.create do |actual_xml_file|
        # parse .jack and write the resulting XML into the temporary file
        actual_xml = `bin/jack_analyzer examples/#{base_name}.jack`
        actual_xml_file.write(actual_xml)
        actual_xml_file.close

        # run the text comparer and remember its exit status
        text_comparer_exit_status = nil
        text_comparer_output, _text_comparer_error = capture_subprocess_io do
          text_comparer_exit_status = system(TEXT_COMPARER_PATH, expected_xml_path, actual_xml_file.path)
        end

        # check that the exit status was `true` (i.e. success)
        assert(text_comparer_exit_status, text_comparer_output)
      end
    end
  end
end

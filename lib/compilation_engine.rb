require 'cgi'

class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
  end

  attr_reader :tokenizer

  def compile_class
    @output.puts("<class>")
    advance_and_output_token
    advance_and_output_token
    advance_and_output_token

    advance
    if [:STATIC, :FIELD].include?(@tokenizer.key_word)
      compile_class_var_dec
    elsif [:CONSTRUCTOR, :FUNCTION, :METHOD, :VOID].include?(@tokenizer.key_word)
      compile_subroutine
    end

    advance_and_output_token
    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")
    output_token

    advance_and_output_token
    advance_and_output_token
    advance_and_output_token
    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    output_token

    advance_and_output_token
    advance_and_output_token
    advance_and_output_token

    compile_parameter_list

    advance_and_output_token
    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")
    @output.puts("</parameterList>")
  end

  private

  def compile_subroutine_body
    @output.puts("<subroutineBody>")

    advance_and_output_token
    advance_and_output_token

    @output.puts("</subroutineBody>")
  end

  def advance_and_output_token
    advance
    output_token
  end

  def advance
    @tokenizer.has_more_tokens? && @tokenizer.advance
  end

  def output_token
    case tokenizer.token_type
    when :STRING_CONST
      token = tokenizer.string_val
      token_type = "stringConstant"
    when :INT_CONST
      token = tokenizer.int_val.to_s
      token_type = "integerConstant"
    when :KEYWORD
      token = tokenizer.key_word.downcase.to_s
      token_type = "keyword"
    when :IDENTIFIER
      token = tokenizer.identifier
      token_type = "identifier"
    when :SYMBOL
      token = tokenizer.symbol
      token_type = "symbol"
    end

    @output.puts("<#{token_type}> #{CGI.escapeHTML(token)} </#{token_type}>")
  end
end

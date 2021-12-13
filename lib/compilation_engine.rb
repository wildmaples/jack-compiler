require 'cgi'

class CompilationEngine
  def initialize(input, output, tokenizer: JackTokenizer.new(input))
    @output = output
    @tokenizer = tokenizer
  end

  attr_reader :tokenizer

  def compile_class
    @output.puts("<class>")
    advance

    output_token # class
    advance

    output_token # className
    advance

    output_token # {
    advance

    case @tokenizer.key_word
    when :STATIC, :FIELD
      compile_class_var_dec
    when :CONSTRUCTOR, :FUNCTION, :METHOD, :VOID
      compile_subroutine
    end

    output_token # }

    @output.puts("</class>")
  end

  def compile_class_var_dec
    @output.puts("<classVarDec>")

    output_token # static / field
    advance

    output_token # type
    advance

    output_token # varName
    advance

    output_token # semicolon
    advance

    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    output_token # constructor / function / method
    advance

    output_token # void / type
    advance

    output_token # subroutineName
    advance

    output_token # (
    advance

    compile_parameter_list

    output_token # )
    advance

    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")

    unless @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ")"
      output_token # type
      advance

      output_token # varName
      advance

      while @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ","
        output_token # ,
        advance

        output_token # type
        advance

        output_token # varName
        advance
      end
    end

    @output.puts("</parameterList>")
  end

  def compile_var_dec
    @output.puts("<varDec>")
    output_token # var
    advance

    output_token # type
    advance

    output_token #varName
    advance

    # TODO: only enter loop when the token is a comma
    until @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ";"
      output_token # ,
      advance

      output_token # varName
      advance
    end

    output_token # ;
    advance

    @output.puts("</varDec>")
  end

  def compile_statements
    @output.puts("<statements>")

    until !@tokenizer.has_more_tokens? || (@tokenizer.token_type == :SYMBOL && @tokenizer.symbol == "}")
      if tokenizer.token_type == :KEYWORD && tokenizer.key_word == :RETURN
        compile_return
      end
    end

    @output.puts("</statements>")
  end

  def compile_return
    @output.puts("<returnStatement>")

    output_token # return
    advance

    output_token # ;
    advance

    @output.puts("</returnStatement>")
  end

  private

  def compile_subroutine_body
    @output.puts("<subroutineBody>")

    output_token # {
    advance

    while @tokenizer.token_type == :KEYWORD && @tokenizer.key_word == :VAR
      compile_var_dec
    end

    if tokenizer.token_type == :KEYWORD
      compile_statements
    end

    output_token # }
    advance

    @output.puts("</subroutineBody>")
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

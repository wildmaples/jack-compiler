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
    output_token # className
    output_token # {

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
    output_token # type
    output_token # varName

    while @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ","
      output_token # ,
      output_token # varName
    end

    output_token # ;

    @output.puts("</classVarDec>")
  end

  def compile_subroutine
    @output.puts("<subroutineDec>")

    output_token # constructor / function / method
    output_token # void / type
    output_token # subroutineName
    output_token # (

    compile_parameter_list

    output_token # )

    compile_subroutine_body

    @output.puts("</subroutineDec>")
  end

  def compile_parameter_list
    @output.puts("<parameterList>")

    unless @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ")"
      output_token # type
      output_token # varName

      while @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ","
        output_token # ,
        output_token # type
        output_token # varName
      end
    end

    @output.puts("</parameterList>")
  end

  def compile_var_dec
    @output.puts("<varDec>")
    output_token # var
    output_token # type
    output_token # varName

    while @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ","
      output_token # ,
      output_token # varName
    end

    output_token # ;

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

    unless @tokenizer.token_type == :SYMBOL && @tokenizer.symbol == ";"
      compile_expression
    end

    output_token # ;

    @output.puts("</returnStatement>")
  end

  def compile_let
    @output.puts("<letStatement>")
    output_token # let
    output_token # varName
    output_token # =

    compile_expression # expression
    
    output_token # ;
    @output.puts("</letStatement>")
  end

  def compile_expression
    @output.puts("<expression>")
    compile_term
    @output.puts("</expression>")
  end

  def compile_term
    @output.puts("<term>")
    output_token # identifier
    @output.puts("</term>")
  end

  private

  def compile_subroutine_body
    @output.puts("<subroutineBody>")

    output_token # {

    while @tokenizer.token_type == :KEYWORD && @tokenizer.key_word == :VAR
      compile_var_dec
    end

    if tokenizer.token_type == :KEYWORD
      compile_statements
    end

    output_token # }

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
    advance
  end
end

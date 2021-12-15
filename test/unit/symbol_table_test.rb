require "test_helper"
require "symbol_table"

class SymbolTableTest < Minitest::Test
  def test_define_adds_new_identifier_to_symbol_table
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    assert_equal(:STATIC, symbol_table.kind_of("foo"))
  end

  def test_type_of_returns_the_type_of_identifier
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    assert_equal("int", symbol_table.type_of("foo"))
  end
end

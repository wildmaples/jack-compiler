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

  def test_index_of_one_returns_index
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    assert_equal(0, symbol_table.index_of("foo"))
  end

  def test_index_of_returns_index_with_various_identifiers
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    symbol_table.define("bar", "boolean", :FIELD)
    symbol_table.define("baz", "char", :STATIC)
    symbol_table.define("too", "boolean", :FIELD)
    symbol_table.define("tar", "int", :STATIC)

    assert_equal(1, symbol_table.index_of("too"))
    assert_equal(2, symbol_table.index_of("tar"))
  end

  def test_var_count_returns_number_of_same_kind_of_identifier
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    symbol_table.define("bar", "boolean", :STATIC)
    assert_equal(2, symbol_table.var_count(:STATIC))
  end

  def test_var_count_returns_number_of_different_kinds_of_identifier
    symbol_table = SymbolTable.new
    symbol_table.define("foo", "int", :STATIC)
    symbol_table.define("bar", "boolean", :FIELD)
    symbol_table.define("baz", "char", :STATIC)

    assert_equal(2, symbol_table.var_count(:STATIC))
    assert_equal(1, symbol_table.var_count(:FIELD))
  end

  def test_start_subroutine_resets_subroutine_scoped_identifiers
    symbol_table = SymbolTable.new
    symbol_table.define("too", "boolean", :ARG)
    symbol_table.define("foo", "int", :STATIC)
    symbol_table.define("bar", "boolean", :STATIC)
    symbol_table.define("tar", "int", :ARG)

    assert_equal(2, symbol_table.var_count(:ARG))
    assert_equal(2, symbol_table.var_count(:STATIC))

    symbol_table.start_subroutine
    
    assert_equal(0, symbol_table.var_count(:ARG))
    assert_equal(2, symbol_table.var_count(:STATIC))
  end
end

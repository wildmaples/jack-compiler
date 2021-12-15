class SymbolTable
  def initialize
    @symbol_table = {}
  end

  attr_reader :symbol_table

  def define(name, type, kind)
    symbol_table[name] = {type: type, kind: kind, index: var_count(kind)}
  end

  def kind_of(name)
    symbol_table[name][:kind]
  end

  def type_of(name)
    symbol_table[name][:type]
  end

  def index_of(name)
    symbol_table[name][:index]
  end

  def var_count(kind)
    symbol_table.values.count { |entry| entry[:kind] == kind }
  end
end

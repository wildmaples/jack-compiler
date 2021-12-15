class SymbolTable
  def initialize
    @symbol_table = {}
  end

  def define(name, type, kind)
    @symbol_table[name] = [type, kind]
  end

  def kind_of(name)
    @symbol_table[name][1]
  end

  def type_of(name)
    @symbol_table[name][0]
  end
end

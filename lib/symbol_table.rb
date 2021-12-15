class SymbolTable
  def initialize
    @symbol_table = {}
  end

  def define(name, type, kind)
    @symbol_table[name] = {type: type, kind: kind}
  end

  def kind_of(name)
    @symbol_table[name][:kind]
  end

  def type_of(name)
    @symbol_table[name][:type]
  end
end

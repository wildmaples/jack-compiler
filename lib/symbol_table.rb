class SymbolTable
  def initialize
    @class_symbol_table = {}
    @subroutine_symbol_table = {}
  end

  def define(name, type, kind)
    case kind
    when :STATIC, :FIELD
      @class_symbol_table[name] = { type: type, kind: kind, index: var_count(kind) }
    when :ARG, :VAR
      @subroutine_symbol_table[name] = { type: type, kind: kind, index: var_count(kind) }
    end
  end

  def kind_of(name)
    symbol_table.fetch(name, { kind: :NONE })[:kind]
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

  def start_subroutine
    @subroutine_symbol_table = {}
  end

  def include?(name)
    symbol_table.key?(name)
  end

  private

  def symbol_table
    @subroutine_symbol_table.merge(@class_symbol_table)
  end
end

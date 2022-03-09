class Utils
  class << self
    def kind_to_segment(kind)
      case kind
      when :VAR
        :LOCAL
      when :FIELD
        :THIS
      else
        kind
      end
    end

    def adjusted_index(name, symbol_table, subroutine_kind)
      variable_kind = symbol_table.kind_of(name)
      index = symbol_table.index_of(name)
      index += 1 if subroutine_kind == :METHOD && variable_kind == :ARG
      index
    end
  end
end

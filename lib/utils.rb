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
  end
end

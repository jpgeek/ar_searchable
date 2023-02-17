module ArSearchable
  class SearchableStruct < OpenStruct
    def clear
      to_h.keys.each {|k| self[k] = nil}
      nil
    end

    def initialize(hash=nil)
      super
      freeze
    end
  end
end

require "ar_searchable/version"
require "ar_searchable/engine"
require "ar_searchable/searchable_struct"
require 'active_support/concern'

module ArSearchable
  extend ActiveSupport::Concern

  included do |base|
    unless base.class_variable_defined?(:@@searchable_methods)
      base.class_variable_set(:@@searchable_methods, [])
    end
  end

  class_methods do
    ################ by_search() ##############

    # Search based on a SearchableStruct (frozen OpenStruct).
    # +searchable+ SearchableStruct
    def by_searchable(searchable)
      unless searchable.is_a? SearchableStruct
        raise ArgumentError, "bad class: #{searchable}"
      end
      ret = all
      searchable.to_h.reject {|k,v| v.blank?}.each_pair do |k,v|
        ret = ret.send("by_#{k}".to_sym ,v)
      end
      ret
    end

    ################ macros: ##############
    ################ dates ##############
    def searchable_date_range(*args)
      args.each do |arg|
        searchable_date_from(arg)
        searchable_date_to(arg)
      end
    end

    def searchable_date_from(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}_from".to_sym) do |date|
          where("#{table_qualified(arg)} >=?", date)
        end
      end
    end

    def searchable_date_to(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}_to".to_sym) do |date|
          where("#{table_qualified(arg)} <=?", date)
        end
      end
    end

    def searchable_date(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}".to_sym) do |date|
          where("#{table_qualified(arg)} = ?", date)
        end
      end
    end

    ################ numeric ##############
    def searchable_numeric(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}".to_sym) do |num|
          where(arg => clean_numeric(num))
        end
      end
    end

    def searchable_numeric_range(*args)
      args.each do |arg|
        searchable_numeric_from(arg)
        searchable_numeric_to(arg)
      end
    end

    def searchable_numeric_from(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}_from".to_sym) do |num|
          where("#{table_qualified(arg)} >=?", clean_numeric(num))
        end
      end
    end

    def searchable_numeric_to(*args)
      args.each do |arg|
        define_searchable_method("#{arg}_to".to_sym) do |num|
          where("#{table_qualified(arg)} <=?", clean_numeric(num))
        end
      end
    end

    ################ string_like ##############
    def searchable_string_like(*args)
      args.each do |arg|
        define_searchable_method( "#{arg}_like".to_sym) do |str|
          where("#{table_qualified(arg)} LIKE ?", "%#{str}%")
        end
      end
    end

    ################ phone_number ##############
    def searchable_phone_number(*args)
      args.each do |arg|
        define_searchable_method("#{arg}".to_sym) do |str|
          by_numerals_in_string(arg, str)
        end
      end
    end

    def searchable_postal_code(*args)
      args.each do |arg|
        define_searchable_method("#{arg}".to_sym) do |str|
          by_numerals_in_string(arg, str)
        end
      end
    end

    ################ static ##############

    # strip non-numeric from needle and haystack and compare with like.
    def by_numerals_in_string(field, str)
      where(
        "REGEXP_REPLACE(#{table_qualified(field)}, '[^0-9]', '') " +
        "LIKE ?", "%#{str.gsub(/\D/, '')}%"
      )
    end

    ################ custom ##############
    def searchable_custom_method(*args)
      args.each do |arg|
        add_searchable_method("#{arg}".to_sym)
      end
    end

    ################ utilities ##############
    def define_searchable_method(name, &block)
      add_searchable_method(name)
      # plain version
      define_singleton_method("by_#{name}", &block)

      # version with _if, returns all if the param is blank.
      define_singleton_method("by_#{name}_if") do |arg|
        return all if arg.blank? 
        block.call(arg)
      end
    end

    def add_searchable_method(name)
      searchable_methods << name.to_sym
    end

    def table_qualified(field)
      "#{table_name}.#{field}"
    end

    def clean_numeric(val)
      return val unless val.is_a?(String)
      val.gsub(',','').to_i
    end

    # return a SearchableStruct, checked for disallowed keys.
    def searchable_struct(hash)
      hsh = hash.to_h
      (hsh.to_h.symbolize_keys.keys - searchable_methods).tap do |invalid|
        raise ArgumentError, 
          "Keys not allowed: #{invalid.join(' ,')}" if invalid.any?
      end
      SearchableStruct.new(hsh)
    end

    # Implement in child if more methods are needed.
    def searchable_methods
      self.class_variable_get(:@@searchable_methods)
    end

    # find unimplemented scopes (search methods).
    def unimplemented_scopes
      ret = [] 
      searchable_parameters.map do |p|
        ret << p unless  respond_to?(p) 
      end
    end
  end
end

require 'test_helper'

class SearchableTest < WithModelTest

  def test_interface_implemented
    #methods = [] # no required methods
    #check_interface_implemented(klasses, methods)
    klasses_with_concern.each do |klass|
      klass.send(:searchable_methods).map do |sp|
        method_name = "by_#{sp}";
        assert klass.respond_to?(method_name.to_sym), 
          "#{method_name} not implemented in #{klass.name}"
      end
    end
  end

  def test_searchable_struct
    assert_raises ArgumentError do
      DummySearchable.searchable_struct(numeric: 7, bar: 'bar')
    end 

    ss = DummySearchable.searchable_struct(numeric: 7)
    assert ss.frozen?
    assert_equal 7, ss.numeric
  end

  def test_string_like_macros
    # year month
    with_dummy_table do
      assert_equal "dummy_searchables.lkstring LIKE '%foo%'",
        DummySearchable.by_lkstring_like('foo').
        where_clause.instance_variable_get(:@predicates).first
    end
  end

  # macros are called in DummySearchable class below, tested here.
  def test_date_scope_definition_macros
    with_dummy_table do
      # date
      assert_equal "dummy_searchables.dt_from >='2019-01-15'",
        DummySearchable.by_dt_from_from(Date.new(2019,1,15)).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.dt_to <='2019-01-15'",
        DummySearchable.by_dt_to_to(Date.new(2019,1,15)).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.dt_range >='2019-01-15'",
        DummySearchable.by_dt_range_from(Date.new(2019,1,15)).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.dt_range <='2019-01-15'",
        DummySearchable.by_dt_range_to(Date.new(2019,1,15)).
        where_clause.instance_variable_get(:@predicates).first
    end
  end


  def test_year_month_scope_definition_macros
    # year month
    with_dummy_table do
      assert_equal "dummy_searchables.ym_from >='2019-01-01'",
        DummySearchable.by_ym_from_from('2019/1').
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.ym_to <='2019-01-01'",
        DummySearchable.by_ym_to_to('2019/1').
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.ym_range >='2019-01-01'",
        DummySearchable.by_ym_range_from('2019/1').
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.ym_range <='2019-01-01'",
        DummySearchable.by_ym_range_to('2019/1').
        where_clause.instance_variable_get(:@predicates).first
    end
  end

  def test_numeric_scope_definition_macros
    # numeric
    # look at where_values_hash instead
    with_dummy_table do
      vals = DummySearchable.by_numeric(42).where_values_hash
      assert vals['numeric'] = 42 

      assert_equal "dummy_searchables.numeric_from >='42'", 
        DummySearchable.by_numeric_from_from(42).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.numeric_to <='42'",
        DummySearchable.by_numeric_to_to(42).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.numeric_range >='42'",
        DummySearchable.by_numeric_range_from(42).
        where_clause.instance_variable_get(:@predicates).first

      assert_equal "dummy_searchables.numeric_range <='42'",
        predicates = DummySearchable.by_numeric_range_to(42).
        where_clause.instance_variable_get(:@predicates).first
    end
  end

  def test_custom_method_scope_definition_macros
    with_dummy_table do
      # look at where_values_hash instead
      assert DummySearchable.searchable_methods.include? :custom_method
      vals = DummySearchable.by_custom_method(42).where_values_hash
      assert vals[:numeric] = 42 
      # by_custom_method() just returns by_numeric(). See DummySearchable
    end
  end

  def test_by_searchable
    ss = DummySearchable.searchable_struct(
      dt_from_from: Date.new(2019,2,15), 
      dt_to_to: Date.new(2019,4,15)
    )
    DummySearchable.by_searchable(ss).
      where_clause.instance_variable_get(:@predicates).tap do |val|
      assert val.include?("dummy_searchables.dt_from >='2019-02-15'")
      assert val.include?("dummy_searchables.dt_to <='2019-04-15'")
    end
  end

  def test_by_postal_code_and_phone
    mod_proc = Proc.new do
      define_model :SearchableClass do
        table do |t|
          t.string :postal_code
          t.string :phone_no
        end
        # The model block is the ActiveRecord model’s class body.
        model do
          include Searchable
          searchable_postal_code :postal_code
          searchable_phone_number :phone_no
        end
      end
    end

    within_model(mod_proc.call) do
      inst = SearchableClass.create(
        postal_code: 'abc12$%() home 34 & 567',
        phone_no: '(123) and some 45-67-8',
      )
      assert SearchableClass.by_postal_code('12-34-56').include?(inst)
      refute SearchableClass.by_postal_code('12-3457').include?(inst)
      assert SearchableClass.by_phone_no('12-34-56').include?(inst)
      refute SearchableClass.by_phone_no('12-34-56-789').include?(inst)

      assert SearchableClass.by_postal_code_if('12-34-56').include?(inst)
      refute SearchableClass.by_postal_code_if('12-3457').include?(inst)
      assert SearchableClass.by_postal_code_if('').include?(inst)
      assert SearchableClass.by_postal_code_if(nil).include?(inst)
    end
  end

  def with_dummy_table
    CreateDummySearchable.migrate(:up)
    yield
    # CreateDummySearchable.migrate(:down)
  end

end

class DummySearchable < ActiveRecord::Base
  include Searchable
  searchable_date_from :dt_from
  searchable_date_to :dt_to
  searchable_date_range :dt_range

  searchable_year_month_from :ym_from
  searchable_year_month_to :ym_to
  searchable_year_month_range :ym_range

  searchable_numeric :numeric
  searchable_numeric_from :numeric_from
  searchable_numeric_to :numeric_to
  searchable_numeric_range :numeric_range

  searchable_string_like :lkstring

  searchable_custom_method :custom_method
  def self.by_custom_method(val)
    by_numeric(val)
  end
end

class CreateDummySearchable < ActiveRecord::Migration[4.2]
  def up
    unless ActiveRecord::Base.connection.table_exists? :dummy_searchables
      create_table :dummy_searchables do |t|
        t.integer :numeric
      end
    end
  end

  def down
    drop_table :dummy_searchables
  end

  # be quiet
  def announce(message); end
  def verbose; false; end
end


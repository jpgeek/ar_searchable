class Foo < ApplicationRecord
  include ArSearchable

  searchable_numeric :numeric
end

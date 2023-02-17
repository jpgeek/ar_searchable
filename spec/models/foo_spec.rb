require 'rails_helper'

RSpec.describe Foo, type: :model do
  it_behaves_like "has a SearchableStruct"
  it_behaves_like "has searchable methods"
end

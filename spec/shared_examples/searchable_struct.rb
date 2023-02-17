shared_examples_for "has a SearchableStruct" do
  let(:model) { described_class }

  context "SearchableStruct" do
    describe "searchable_struct" do
      context "with a struct defined" do
        let(:ss) do
          model.searchable_struct(numeric: 7)
        end

        it "returns the searchable struct" do
          expect(ss.numeric).to eq(7)
        end

        it "raises and error if searched for non-specified values" do
          expect { model.searchable_struct(numeric: 7, bar: 'bar') }
            .to raise_error(ArgumentError)
        end

        it "freezes the struct" do
          expect(ss).to be_frozen
        end
      end
    end
  end
end

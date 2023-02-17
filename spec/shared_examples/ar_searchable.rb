shared_examples_for "has searchable methods" do
  context "when searching dates" do
    let(:start_date) { Date.new(2023, 5, 1) }
    let(:end_date) { Date.new(2023, 5, 10) }
    let!(:record) do
      described_class.create(start_date: start_date, end_date: end_date)
    end

    describe '.searchable_date_from' do
      before(:all) do
        described_class.module_eval(%q{searchable_date_from :start_date})
      end

      it "includes record for the date" do
        expect(described_class.by_start_date_from(start_date))
          .to include(record)
      end

      it "includes record for 1 day before the date" do
        expect(described_class.by_start_date_from(start_date - 1.day))
          .to include(record)
      end

      it "excludes record for 1 day after the date" do
        expect(described_class.by_start_date_from(start_date + 1.day))
          .not_to include(record)
      end
    end

    describe '.searchable_date_to' do
      before(:all) do
        described_class.module_eval(%q{searchable_date_to :end_date})
      end

      it "includes record for the date" do
        expect(described_class.by_end_date_to(end_date))
          .to include(record)
      end

      it "excludes record for 1 day before the date" do
        expect(described_class.by_end_date_to(end_date - 1.day))
          .not_to include(record)
      end

      it "includes record for 1 day after the date" do
        expect(described_class.by_end_date_to(end_date + 1.day))
          .to include(record)
      end
    end

    describe '.searchable_date_range' do
      before(:all) do
        described_class.module_eval(%q{searchable_date_range :end_date})
      end

      it "creates date_from" do
        expect(described_class.by_end_date_from(end_date))
          .to include(record)
      end

      it "creates date_to" do
        expect(described_class.by_end_date_to(end_date))
          .to include(record)
      end
    end

    describe '.searchable_date' do
      before(:all) do
        described_class.module_eval(%q{searchable_date :start_date})
      end

      it "includes record for the date" do
        expect(described_class.by_start_date(start_date))
          .to include(record)
      end

      it "excludes record for 1 day before the date" do
        expect(described_class.by_start_date(start_date - 1.day))
          .not_to include(record)
      end

      it "excludes record for 1 day after the date" do
        expect(described_class.by_start_date(start_date + 1.day))
          .not_to include(record)
      end
    end
  end


  context "when searching numeric" do
    let(:start) { 42 }
    let(:finish) { 45 }
    let!(:record) do
      described_class.create(widget_count: start)
    end

    describe '.searchable_numeric' do
      before(:all) do
        described_class.module_eval(%q{searchable_numeric :widget_count})
      end

      it "includes record for the value" do
        expect(described_class.by_widget_count(start))
          .to include(record)
      end

      it "excludes record for 1 less than the value" do
        expect(described_class.by_widget_count(start - 1))
          .not_to include(record)
      end

      it "excludes record for 1 more than the value" do
        expect(described_class.by_widget_count(start + 1))
          .not_to include(record)
      end
    end

    describe '.searchable_numeric_from' do
      before(:all) do
        described_class.module_eval(%q{searchable_numeric_from :widget_count})
      end

      it "includes record for the value" do
        expect(described_class.by_widget_count_from(start))
          .to include(record)
      end

      it "includes record for 1 less than the value" do
        expect(described_class.by_widget_count_from(start - 1))
          .to include(record)
      end

      it "excludes record for 1 more than the value" do
        expect(described_class.by_widget_count_from(start + 1))
          .not_to include(record)
      end
    end

    describe '.searchable_numeric_to' do
      before(:all) do
        described_class.module_eval(%q{searchable_numeric_to :widget_count})
      end

      it "includes record for the value" do
        expect(described_class.by_widget_count_to(start))
          .to include(record)
      end

      it "excludes record for 1 less than the value" do
        expect(described_class.by_widget_count_to(start - 1))
          .not_to include(record)
      end

      it "includes record for 1 more than the value" do
        expect(described_class.by_widget_count_to(start + 1))
          .to include(record)
      end
    end


    describe '.searchable_numeric_range' do
      before(:all) do
        described_class.module_eval(%q{searchable_numeric_range :widget_count})
      end

      it "creates _to method" do
        expect(described_class.by_widget_count_to(start))
          .to include(record)
      end

      it "creates _from method" do
        expect(described_class.by_widget_count_from(start))
          .to include(record)
      end
    end
  end


  describe '.searchable_string_like' do
    before(:all) { described_class.module_eval(%q{searchable_string_like :name}) }
    let!(:bob) { described_class.create(name: 'Bobicus') }

    context 'without _if' do
      subject(:relation) { described_class.by_name_like(name_fragment) }

      context 'with matching fragment' do
        let(:name_fragment) { 'bicus' }

        it { is_expected.to include(bob) }
      end

      context 'with different case matching fragment' do
        let(:name_fragment) { 'Bicus' }

        it { is_expected.to include(bob) }
      end

      context 'with non matching fragment' do
        let(:name_fragment) { 'Xicus' }

        it { is_expected.not_to include(bob) }
      end
    end

    context 'with _if' do
      let!(:fred) { described_class.create(name: 'Fred') }
      subject(:relation) { described_class.by_name_like_if(name_fragment) }

      context 'with matching fragment' do
        let(:name_fragment) { 'bicus' }

        it { is_expected.to include(bob) }
      end

      context 'with blank fragment' do
        let(:name_fragment) { '' }

        it "applies no filters and returns all records" do 
          expect(relation).to include(bob)
        end
      end
    end
  end
end

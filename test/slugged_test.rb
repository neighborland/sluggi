require 'test_helper'

class SluggedTest < MiniTest::Spec
  class ::Cat < ActiveRecord::Base
    include Sluggi::Slugged

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  class ::CandidateCat < ActiveRecord::Base
    self.table_name = 'cats'
    include Sluggi::Slugged

    def slug_candidates
      [nil, name]
    end

    def slug_value_changed?
      name_changed?
    end
  end

  class ::IncompleteCat < ActiveRecord::Base
    self.table_name = 'cats'
    include Sluggi::Slugged
  end

  it "raises when slug_value is not implemented" do
    assert_raises(NotImplementedError) do
      IncompleteCat.new.valid?
    end
  end

  describe "#to_param" do
    before do
      Cat.delete_all
      @cat = Cat.new(name: 'Tuxedo Stan')
    end

    it "is nil when new" do
      assert_nil @cat.to_param
    end

    it "is the slug when persisted" do
      @cat.save!
      assert_equal 'tuxedo-stan', @cat.to_param
    end

    it "is the old slug when changed but not saved" do
      @cat.save!
      @cat.slug = 'ketzel'
      assert_equal 'tuxedo-stan', @cat.to_param
    end
  end

  describe ".reserved_slugs" do
    %w(create login users).each do |word|
      it "includes #{word}" do
        assert_includes Cat.reserved_slugs, word
      end
    end

    it "does not include valid slug" do
      refute_includes Cat.reserved_slugs, 'something'
    end
  end

  describe "validation" do
    it "reserved slug is invalid" do
      refute Cat.new(name: 'edit').valid?
    end

    it "blank slug is invalid" do
      refute Cat.new(name: '').valid?
    end

    it "sets slug on validation" do
      cat = Cat.new(name: 'Prince Chunk')
      assert cat.valid?
      assert_equal 'prince-chunk', cat.slug
    end

    it "is invalid when slug is taken" do
      Cat.create(slug: 'mrs-chippy')
      cat = Cat.new(name: 'Mrs. Chippy')
      refute cat.valid?
      assert_nil cat.to_param
    end
  end

  describe "candidates" do
    it "sets slug from candidates on validation" do
      cat = CandidateCat.new(name: 'Smokey')
      assert cat.valid?
      assert_equal 'smokey', cat.slug
    end
  end

end

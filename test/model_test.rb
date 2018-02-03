# frozen_string_literal: true

require "test_helper"

class ModelTest < MiniTest::Spec
  class IncompleteCat < ActiveRecord::Base
    self.table_name = "cats"
    include Sluggi::Model
  end

  class Cat < ActiveRecord::Base
    include Sluggi::Model

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  class CandidateCat < ActiveRecord::Base
    self.table_name = "cats"
    include Sluggi::Model

    def slug_candidates
      [nil, name]
    end

    def slug_value_changed?
      name_changed?
    end
  end

  it "raises when slug_value is not implemented" do
    assert_raises(NotImplementedError) do
      IncompleteCat.new.valid?
    end
  end

  describe "#to_param" do
    before do
      @cat = Cat.new(name: "Tuxedo Stan")
    end

    it "is nil when new" do
      assert_nil @cat.to_param
    end

    it "is the slug when persisted" do
      @cat.save!
      assert_equal "tuxedo-stan", @cat.to_param
    end

    it "is the old slug when record is invalid" do
      @cat.save!
      @cat.slug = "ketzel"
      @cat.errors.add(:name, "something is wrong")
      assert_equal "tuxedo-stan", @cat.to_param
    end
  end

  it "sets slug from candidates on validation" do
    cat = CandidateCat.new(name: "Smokey")
    assert cat.valid?
    assert_equal "smokey", cat.slug
  end

  it "sets slug on validation" do
    cat = Cat.new(name: "Prince Chunk")
    assert cat.valid?
    assert_equal "prince-chunk", cat.slug
  end
end

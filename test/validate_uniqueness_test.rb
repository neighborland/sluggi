# frozen_string_literal: true

require "test_helper"

class ValidateUniquenessTest < MiniTest::Spec
  class Cat < ActiveRecord::Base
    include Sluggi::Model
    include Sluggi::ValidateUniqueness

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  it "validates slug is unique" do
    Cat.create(slug: "mrs-chippy")
    cat = Cat.new(name: "Mrs. Chippy")
    refute cat.valid?
    assert_equal "has already been taken", cat.errors[:slug].first
    assert_nil cat.to_param
  end

  it "does not validate uniqueness when slug is unchanged" do
    cat = Cat.create(slug: "garfield")
    cat.factoid = "factoid"
    refute cat.slug_value_changed?
    ActiveRecord::Validations::UniquenessValidator.any_instance.expects(:validate_each).never
    assert cat.valid?
  end
end

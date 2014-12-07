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
    Cat.create(slug: 'mrs-chippy')
    cat = Cat.new(name: 'Mrs. Chippy')
    refute cat.valid?
    assert_nil cat.to_param
  end

end

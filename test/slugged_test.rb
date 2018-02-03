# frozen_string_literal: true

require "test_helper"

class SluggedTest < MiniTest::Spec
  class Cat < ActiveRecord::Base
    include Sluggi::Slugged

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  it "includes ValidatePresence" do
    assert Cat.new.is_a? Sluggi::ValidatePresence
  end

  it "includes ValidateUniqueness" do
    assert Cat.new.is_a? Sluggi::ValidateUniqueness
  end

  it "includes ValidateExclusionOf" do
    assert Cat.new.is_a? Sluggi::ValidateExclusionOf
  end

  it "includes Model" do
    assert Cat.new.is_a? Sluggi::Model
  end
end

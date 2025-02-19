# frozen_string_literal: true

require "test_helper"

class ValidatesExclusionOfTest < Minitest::Spec
  class Cat < ActiveRecord::Base
    include Sluggi::ValidateExclusionOf
  end

  describe ".reserved_slugs" do
    %w[edit new].each do |word|
      it "includes #{word}" do
        assert_includes Cat.reserved_slugs, word
      end
    end

    it "does not include valid slug" do
      refute_includes Cat.reserved_slugs, "something"
    end
  end

  describe "validation" do
    it "ensures slug is not a reserved word" do
      refute Cat.new(slug: "edit").valid?
    end
  end
end

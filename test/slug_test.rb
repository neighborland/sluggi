require 'test_helper'

module Sluggi
  class SlugTest < MiniTest::Spec
    describe "validation" do
      it "is not valid" do
        slug = Slug.new
        refute slug.valid?
      end

      it "is valid" do
        slug = Slug.new(sluggable_type: 'Cat', sluggable_id: 1, slug: 'garfield')
        assert slug.valid?
      end
    end

    describe ".find_type" do
      it "finds" do
        slug = Slug.create(sluggable_type: 'Cat', sluggable_id: 1, slug: 'garfield')
        assert_equal slug, Slug.find_type('garfield', 'Cat').first
      end
    end

    describe "#to_param" do
      it "is nil" do
        assert_nil Slug.new.to_param
      end

      it "is slug" do
        assert_equal 'meow', Slug.new(slug: 'meow').to_param
      end
    end

  end
end

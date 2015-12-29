require 'test_helper'

class HistoryTest < MiniTest::Spec
  class ::Cat < ActiveRecord::Base
    include Sluggi::Slugged
    include Sluggi::History

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  class ::Dog < ActiveRecord::Base
    include Sluggi::Slugged
    include Sluggi::History

    def slug_value
      name
    end

    def slug_value_changed?
      name_changed?
    end
  end

  class ::BigDog < ::Dog
  end

  class ::LittleDog < ::Dog
  end

  before do
    Cat.delete_all
    Sluggi::Slug.delete_all
  end

  describe ".find_slug!" do
    it "finds current slug" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      assert_equal cat, Cat.find_slug!('tsim-tung-brother-cream')
    end

    it "finds both current and historical slug" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      cat.name = 'Cream Aberdeen'
      cat.save!
      assert_equal cat, Cat.find_slug!('tsim-tung-brother-cream')
      assert_equal cat, Cat.find_slug!('cream-aberdeen')
    end

    it "raises when not found" do
      assert_raises(ActiveRecord::RecordNotFound) do
        Cat.find_slug! 'garfield'
      end
    end

    it "finds STI classes" do
      big_dog = BigDog.create(name: 'Snoop')
      assert_equal big_dog, Dog.find_slug!('snoop')
      assert_equal big_dog, BigDog.find_slug!('snoop')
      error = assert_raises(ActiveRecord::RecordNotFound) do
        LittleDog.find_slug!('snoop')
      end
      assert_equal "Couldn't find LittleDog with 'slug'='snoop'", error.message
    end
  end

  describe ".slug_exists?" do
    it "exists" do
      Cat.create(name: 'Tsim Tung Brother Cream')
      assert Cat.slug_exists?('tsim-tung-brother-cream')
    end

    it "does not exist" do
      refute Cat.slug_exists?('tsim-tung-brother-cream')
    end
  end

  describe ".find_slugs" do
    it "is empty" do
      assert_empty Cat.find_slugs('garfield')
    end

    it "finds historical slug" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      slugs = Cat.find_slugs('tsim-tung-brother-cream')
      assert_equal 1, slugs.size
      slug = slugs.first
      assert_equal 'tsim-tung-brother-cream', slug.slug
      assert_equal 'Cat', slug.sluggable_type
      assert_equal cat.id, slug.sluggable_id
    end
  end

  describe ".after_save" do
    it "creates a slug when model is created" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      assert_equal 1, cat.slugs.size
      assert_equal 'tsim-tung-brother-cream', cat.slugs.first.slug
    end

    it "creates a slug when model slug changes" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      cat.name = 'Cream Aberdeen'
      cat.save!
      assert_equal 2, cat.slugs.size
      assert_equal ['cream-aberdeen', 'tsim-tung-brother-cream'], cat.slugs.map(&:slug)
    end

    it "does not create a slug when model slug is unchanged" do
      cat = Cat.create(name: 'Tsim Tung Brother Cream')
      cat.factoid = 'aka Cream Aberdeen'
      cat.save!
      assert_equal 1, cat.slugs.size
      assert_equal 'tsim-tung-brother-cream', cat.slugs.first.slug
    end
  end
end

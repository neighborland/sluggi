module Sluggi
  module History
    extend ActiveSupport::Concern

    included do
      has_many :slugs, -> { order('slugs.id DESC') }, class_name: 'Sluggi::Slug', as: :sluggable, dependent: :destroy
      after_save :create_slug
    end

    module ClassMethods
      def find_slug!(slug)
        where(slug: slug).first ||
          find_slugs(slug).first.try(:sluggable) ||
          raise(ActiveRecord::RecordNotFound)
      end

      def slug_exists?(slug)
        where(slug: slug).exists? || find_slugs(slug).exists?
      end

      def find_slugs(slug)
        Slug.find_type(slug, base_class.to_s)
      end
    end

  private

    def create_slug
      value = clean_slug(slug_value)
      return if value.blank?
      return if slugs.first.try(:slug) == value
      self.class.find_slugs(value).delete_all # revert to previous slug & put first
      slugs.create(slug: value)
    end

  end
end

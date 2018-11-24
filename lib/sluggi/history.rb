# frozen_string_literal: true

module Sluggi
  module History
    extend ActiveSupport::Concern

    included do
      has_many :slugs,
        -> { order("slugs.id DESC") },
        class_name: "Sluggi::Slug",
        as: :sluggable,
        dependent: :destroy

      after_save :create_slug, if: :saved_change_to_slug_value?
    end

    module ClassMethods
      def find_slug!(slug)
        object = find_by(slug: slug) || find_slugs(slug).first&.sluggable
        unless object.is_a?(self)
          raise ActiveRecord::RecordNotFound, "Couldn't find #{name} with 'slug'='#{slug}'"
        end
        object
      end

      def slug_exists?(slug)
        where(slug: slug).exists? || find_slugs(slug).exists?
      end

      def find_slugs(slug)
        Slug.find_type(slug, base_class.to_s)
      end
    end

    private

    def saved_change_to_slug_value?
      raise NotImplementedError, "You must implement #saved_change_to_slug_value?"
    end

    def create_slug
      return if slug.blank?
      return if slugs.first&.slug == slug
      self.class.find_slugs(slug).delete_all # revert to previous slug & put first
      slugs.create(slug: slug)
    end
  end
end

# frozen_string_literal: true

module Sluggi
  module Model
    extend ActiveSupport::Concern

    NOT_IMPLEMENTED_MESSAGE = "You must implement #slug_value_changed? " \
                              "and either #slug_value or #slug_candidates"

    included do
      before_validation :set_slug
    end

    module ClassMethods
      # Define this so that History can override it.
      def slug_exists?(name)
        exists?(slug: name)
      end
    end

    def to_param
      errors.any? ? slug_was : slug
    end

    private

    def clean_slug(value)
      value&.parameterize
    end

    def set_slug
      return unless new_record? || slug_value_changed?
      new_slug = clean_slug(slug_value)
      return if new_slug.blank?
      self.slug = new_slug
    end

    # these are generally good to override:

    def slug_value
      slug_candidates.each do |item|
        value = item.respond_to?(:call) ? item.call : item
        next if value.blank?
        candidate = clean_slug(value)
        return candidate if candidate == slug
        return candidate unless self.class.slug_exists?(candidate)
      end
      nil
    end

    # return an array of candidate slug values
    # Example:
    #   [first_name, full_name, id_and_full_name]
    def slug_candidates
      raise NotImplementedError, NOT_IMPLEMENTED_MESSAGE
    end

    def slug_value_changed?
      raise NotImplementedError, NOT_IMPLEMENTED_MESSAGE
    end
  end
end

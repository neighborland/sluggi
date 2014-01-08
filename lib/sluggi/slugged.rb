module Sluggi
  module Slugged
    extend ActiveSupport::Concern

    RESERVED_SLUGS = %w(
      create
      edit
      index
      new
      update
      admin
      assets
      images
      javascripts
      login
      logout
      stylesheets
      session
      users
    )

    NOT_IMPLEMENTED_MESSAGE = 'You must implement #slug_value_changed? and either #slug_value or #slug_candidates'

    included do
      before_validation :set_slug
      validates :slug, presence: true, uniqueness: true
      validates_exclusion_of :slug, in: ->(_) { reserved_slugs }
    end

    module ClassMethods
      def reserved_slugs
        RESERVED_SLUGS
      end
    end

    def to_param
      slug_was
    end

  private

    def clean_slug(value)
      value.try :parameterize
    end

    def set_slug
      return unless new_record? || slug_value_changed?
      new_slug = clean_slug(slug_value)
      return if new_slug.blank?
      self.slug = new_slug
    end

    # these are generally good to override:

    def slug_value
      slug_candidates.each do |value|
        next if value.blank?
        candidate = clean_slug(value)
        return candidate if candidate == slug
        return candidate unless self.class.exists?(slug: candidate)
      end
      nil
    end

    # return an array of candidate slug values
    # Example:
    #   [first_name, full_name, id_and_full_name]
    def slug_candidates
      raise NotImplementedError.new(NOT_IMPLEMENTED_MESSAGE)
    end

    def slug_value_changed?
      raise NotImplementedError.new(NOT_IMPLEMENTED_MESSAGE)
    end

  end
end

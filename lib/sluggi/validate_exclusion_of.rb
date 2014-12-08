module Sluggi
  module ValidateExclusionOf
    extend ActiveSupport::Concern

    RESERVED_SLUGS = %w(
      admin
      assets
      create
      edit
      images
      index
      javascripts
      login
      logout
      new
      session
      stylesheets
      update
      users
    )

    included do
      validates_exclusion_of :slug, in: ->(_) { reserved_slugs }
    end

    module ClassMethods
      def reserved_slugs
        RESERVED_SLUGS
      end
    end
  end
end

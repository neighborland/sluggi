module Sluggi
  module ValidateExclusionOf
    extend ActiveSupport::Concern

    RESERVED_SLUGS = %w[
      edit
      new
    ].freeze

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

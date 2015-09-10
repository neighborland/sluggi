module Sluggi
  module ValidateUniqueness
    extend ActiveSupport::Concern

    included do
      validates :slug, uniqueness: true, if: :slug_value_changed?
    end
  end
end

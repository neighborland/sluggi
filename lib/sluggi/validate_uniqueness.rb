module Sluggi
  module ValidateUniqueness
    extend ActiveSupport::Concern

    included do
      validates :slug, uniqueness: true
    end
  end
end

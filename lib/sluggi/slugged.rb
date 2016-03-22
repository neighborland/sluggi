module Sluggi
  module Slugged
    extend ActiveSupport::Concern

    included do
      include Sluggi::Model
      include Sluggi::ValidateExclusionOf
      include Sluggi::ValidatePresence
      include Sluggi::ValidateUniqueness
    end
  end
end

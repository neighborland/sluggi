module Sluggi
  module Slugged
    extend ActiveSupport::Concern
    included do
      include Sluggi::ValidatePresence
      include Sluggi::ValidateUniqueness
      include Sluggi::ValidateExclusionOf
      include Sluggi::Model
    end
  end
end

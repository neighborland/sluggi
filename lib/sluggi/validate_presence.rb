# frozen_string_literal: true

module Sluggi
  module ValidatePresence
    extend ActiveSupport::Concern

    included do
      validates :slug, presence: true
    end
  end
end

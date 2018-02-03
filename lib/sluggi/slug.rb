# frozen_string_literal: true

module Sluggi
  class Slug < ActiveRecord::Base
    belongs_to :sluggable, polymorphic: true

    validates :slug, presence: true
    validates :sluggable_id, presence: true
    validates :sluggable_type, presence: true

    class << self
      def find_type(slug, sluggable_type)
        where(slug: slug, sluggable_type: sluggable_type).order(id: :desc)
      end
    end

    def to_param
      slug
    end
  end
end

# frozen_string_literal: true

# require 'coveralls'
# Coveralls.wear!

require "minitest/autorun"
require "sqlite3"
require "sluggi"

begin
  require "debug"
rescue LoadError
  # ok
end

ActiveRecord::Base.logger = Logger.new($stderr) if ENV["VERBOSE"]

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

unless ActiveRecord::Base.connection.data_sources.include?("cats")
  ActiveRecord::Schema.define do
    create_table :cats do |t|
      t.datetime :created_at
      t.string :factoid
      t.string :name
      t.string :slug, null: false
    end

    create_table :slugs do |t|
      t.string :slug, null: false
      t.integer :sluggable_id, null: false
      t.string :sluggable_type
      t.datetime :created_at
    end

    create_table :dogs do |t|
      t.datetime :created_at
      t.string :type
      t.string :name
      t.string :slug, null: false
    end
  end
end

I18n.enforce_available_locales = true

# suppress deprecation warning
ActiveSupport.test_order = :random

# Thanks to this List of Cats: http://en.wikipedia.org/wiki/List_of_cats

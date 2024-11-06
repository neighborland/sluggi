# frozen_string_literal: true

# This script compares performance of sluggi vs friendly_id
# TO RUN:
# Edit the FRIENDLY value below
# ruby bench.rb

FRIENDLY = !ENV["FRIENDLY"].nil?

# --------------

require "active_record"
require "benchmark"
require "ffaker"
require "sqlite3"
require "byebug"

if FRIENDLY
  require "friendly_id"
else
  require "sluggi"
end

puts "FRIENDLY: #{FRIENDLY}"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

Book = Class.new ActiveRecord::Base

class Journalist < ActiveRecord::Base
  if FRIENDLY
    extend FriendlyId
    friendly_id :name, use: :slugged
  else
    include Sluggi::Model
    def slug_value_changed?
      name_changed?
    end

    def slug_candidates
      [name, -> { "#{name}-#{rand(999_999)}" }]
    end
  end
end

class Manual < ActiveRecord::Base
  if FRIENDLY
    extend FriendlyId
    friendly_id :name, use: :history
  else
    include Sluggi::Model
    include Sluggi::History
    def slug_value_changed?
      name_changed?
    end

    def saved_change_to_slug_value?
      saved_change_to_name?
    end

    def slug_candidates
      [name, -> { "#{name}-#{rand(999_999)}" }]
    end
  end
end

class Restaurant < ActiveRecord::Base
  if FRIENDLY
    extend FriendlyId
    friendly_id :name, use: %i[slugged finders]
  else
    include Sluggi::Model
    def slug_value_changed?
      name_changed?
    end

    def slug_candidates
      [name, -> { "#{name}-#{rand(999_999)}" }]
    end
  end
end

ActiveRecord::Schema.define do
  if FRIENDLY
    create_table :friendly_id_slugs do |t|
      t.string   :slug,           null: false
      t.integer  :sluggable_id,   null: false
      t.string   :sluggable_type, limit: 50
      t.string   :scope
      t.datetime :created_at
    end
    add_index :friendly_id_slugs, %i[sluggable_type sluggable_id]
    add_index :friendly_id_slugs, %i[slug sluggable_type],
              length: { slug: 140, sluggable_type: 50 }
    add_index :friendly_id_slugs, %i[slug sluggable_type scope],
              length: { slug: 70, sluggable_type: 50, scope: 70 }, unique: true
  else
    create_table :slugs do |t|
      t.string :slug, null: false
      t.integer :sluggable_id, null: false
      t.string :sluggable_type, null: false
      t.datetime :created_at
    end

    add_index :slugs, %i[slug sluggable_type], unique: true
    add_index :slugs, :sluggable_id
  end

  %w[books journalists manuals restaurants].each do |table_name|
    create_table table_name do |t|
      t.string :name
      t.string :slug
    end
    add_index table_name, :slug, unique: true
  end
end

books       = []
journalists = []
manuals     = []
restaurants = []

100.times do
  name = FFaker::Name.name
  books << (Book.create! name: name).id
  if FRIENDLY
    journalists << (Journalist.create! name: name).friendly_id
    manuals     << (Manual.create! name: name).friendly_id
    restaurants << (Restaurant.create! name: name).friendly_id
  else
    journalists << (Journalist.create! name: name).slug
    manuals     << (Manual.create! name: name).slug
    restaurants << (Restaurant.create! name: name).slug
  end
end

ActiveRecord::Base.connection.execute "UPDATE manuals SET slug = NULL"

N = 1000

Benchmark.bmbm do |x|
  x.report "find (id) - direct ActiveRecord" do
    N.times { Book.find books.sample }
  end

  x.report "find (in-table slug)" do
    if FRIENDLY
      N.times { Journalist.friendly.find journalists.sample }
    else
      N.times { Journalist.find_by slug: journalists.sample }
    end
  end

  x.report "find (in-table slug; using finders module)" do
    if FRIENDLY
      N.times { Restaurant.find restaurants.sample }
    else
      N.times { Restaurant.find_by slug: restaurants.sample }
    end
  end

  x.report "find (external slug)" do
    if FRIENDLY
      N.times { Manual.friendly.find manuals.sample }
    else
      N.times { Manual.find_slug! manuals.sample }
    end
  end

  x.report "insert (plain AR / no slug)" do
    N.times { Book.create! name: FFaker::Name.name }
  end

  x.report "insert (in-table-slug)" do
    N.times { Journalist.create! name: FFaker::Name.name }
  end

  x.report "insert (in-table-slug; using finders module)" do
    N.times { Restaurant.create! name: FFaker::Name.name }
  end

  x.report "insert (external slug)" do
    N.times { Manual.create! name: FFaker::Name.name }
  end
end

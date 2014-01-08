#require 'coveralls'
#Coveralls.wear!

require 'minitest/autorun'
require 'active_support'
require 'active_record'
require 'sqlite3'
require 'sluggi'

ActiveRecord::Base.logger = Logger.new(STDERR) if ENV["VERBOSE"]
 
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

unless ActiveRecord::Base.connection.tables.include?('cats')
  ActiveRecord::Schema.define do  
    create_table :cats do |t|
      t.datetime :created_at
      t.string :factoid
      t.string :name
      t.string :slug
    end

    create_table :slugs do |t|
      t.string   :slug,         null: false
      t.integer  :sluggable_id, null: false
      t.string   :sluggable_type
      t.datetime :created_at
    end
  end
end

I18n.enforce_available_locales = true

# Thanks to this List of Cats: http://en.wikipedia.org/wiki/List_of_cats
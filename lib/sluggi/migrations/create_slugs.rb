# frozen_string_literal: true

class CreateSlugs < ActiveRecord::Migration
  def change
    create_table :slugs do |t|
      t.string :slug, null: false
      t.integer :sluggable_id, null: false
      t.string :sluggable_type, null: false
      t.datetime :created_at
    end

    add_index :slugs, %i[slug sluggable_type], unique: true
    add_index :slugs, :sluggable_id
  end
end

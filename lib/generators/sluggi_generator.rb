# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

# Copy the migration to create the slugs table.
class SluggiGenerator < ActiveRecord::Generators::Base
  argument :name, type: :string, default: "required_but_not_used"
  source_root File.expand_path(__dir__)

  # Copy the migration template to db/migrate.
  def copy_files
    migration_template "create_slugs.erb.rb", "db/migrate/create_slugs.rb"
  end
end

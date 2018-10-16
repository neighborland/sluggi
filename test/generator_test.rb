# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"

class GeneratorTest < Rails::Generators::TestCase
  tests ::SluggiGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  test "generate a migration" do
    begin
      run_generator
      assert_migration "db/migrate/create_slugs"
    ensure
      FileUtils.rm_rf destination_root
    end
  end
end

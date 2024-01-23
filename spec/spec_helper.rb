# frozen_string_literal: true

require 'permission_settings'

require_relative 'support/db_config'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { DbConfig.clear_db }

  config.after(:suite) { DbConfig.rollback_db }
end

DbConfig.setup_db

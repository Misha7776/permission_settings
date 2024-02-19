# frozen_string_literal: true

# require 'byebug'
require 'active_record'
require 'generators/rails_settings/migration/templates/migration'
require 'rails-settings'

require_relative 'user'

module DbConfig
  def self.setup_db
    config_active_record
    print "Testing with ActiveRecord #{ActiveRecord::VERSION::STRING}"
    puts

    RailsSettingsMigration.migrate(:up)

    config_schema
  end

  def self.clear_db
    User.delete_all
    RailsSettings::SettingObject.delete_all
  end

  def self.config_active_record
    ActiveRecord::Base.configurations = YAML.load_file("#{File.dirname(__FILE__)}/database.yml")
    ActiveRecord::Base.establish_connection(:sqlite)
    ActiveRecord::Migration.verbose = false
  end

  def self.config_schema
    ActiveRecord::Schema.define(version: 1) do
      create_table :users do |t|
        t.string :role
      end
    end
  end

  def self.rollback_db
    RailsSettingsMigration.migrate(:down)
  end
end

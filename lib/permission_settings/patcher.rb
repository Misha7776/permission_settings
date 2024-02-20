# frozen_string_literal: true

# require 'byebug'
require 'active_record'
require 'rails-settings'
require_relative 'verify_instance'

module PermissionSettings
  # Class that defines core functionality
  class Patcher
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def self.call(klass)
      new(klass).call
    end

    def call
      check_permissions_dir
      setup_settings_interface
      setup_instance_verification
      setup_permissions_method
    end

    private

    def check_permissions_dir
      path = PermissionSettings.configuration.permissions_dir_path
      return if Dir.exist?(path)

      raise PermissionSettings::Configuration::PermissionsDirNotFound, dir_missing_message(path)
    end

    def dir_missing_message(path)
      "Permissions config directory not found. Please create a directory at #{path} and add permission files there."
    end

    def setup_settings_interface
      klass.class_eval do
        has_settings do |s|
          s.key PermissionSettings.configuration.scope_name(self),
                defaults: PermissionSettings.configuration.load_permissions_file(self)
        end
      end
    end

    def setup_instance_verification
      role_method = PermissionSettings.configuration.role_access_method

      klass.class_eval do
        define_method(:can?) do |*keys, resource: nil, &block|
          PermissionSettings::VerifyInstance.call(keys,
                                                  role: send(role_method),
                                                  resource: resource,
                                                  &block)
        end
      end
    end

    def setup_permissions_method
      klass.class_eval do
        define_method(:permissions) do
          scope = PermissionSettings.configuration.scope_name(self.class)
          settings(scope).then do |permissions|
            return ActiveSupport::HashWithIndifferentAccess.new(permissions.value) if permissions.value.present?

            ActiveSupport::HashWithIndifferentAccess.new(default_settings[scope])
          end
        end
      end
    end
  end
end

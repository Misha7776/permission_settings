# frozen_string_literal: true

require 'byebug'
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
      setup_settings_interface
      setup_instance_verification
    end

    private

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
          PermissionSettings::VerifyInstance.call(keys, role: send(role_method), resource: resource, &block)
        rescue NameError => _e
          # TODO: Add logger for errors
          false
        end
      end
    end
  end
end

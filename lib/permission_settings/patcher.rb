# frozen_string_literal: true

require_relative 'verify_instance'
require_relative 'verify_collection'
require 'rails-settings/configuration'
require 'rails-settings/base'
require 'rails-settings/scopes'

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
      # setup_collection_verification
    end

    private

    def setup_settings_interface
      klass.class_eval do
        def self.has_settings(*args, &block)
          RailsSettings::Configuration.new(*args.unshift(self), &block)

          include RailsSettings::Base
          extend RailsSettings::Scopes
        end
      end
    end

    def setup_instance_verification
      klass.class_eval do
        define_method(:can?) do |*keys, resource: nil, &block|
          PermissionSettings::VerifyInstance.call(keys, role: send(:role), resource: resource, &block)
        rescue NameError => _e
          # TODO: Add logger for errors
          false
        end
      end
    end

    # def setup_collection_verification
    #   klass.instance_eval do
    #     define_singleton_method(:with_ability_to) do |*keys, resource: nil, roles: nil|
    #       PermissionSettings::VerifyCollection.call(all, keys, role: send(:role), resource: resource, roles: roles)
    #     rescue NameError => _e
    #       # TODO: Add logger for errors
    #       all
    #     end
    #   end
    # end
  end
end

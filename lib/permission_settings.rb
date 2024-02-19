# frozen_string_literal: true

# require 'byebug'

require_relative 'permission_settings/version'
require_relative 'permission_settings/patcher'
require_relative 'permission_settings/configuration'

# Gem entrypoint
module PermissionSettings
  class NotFoundError < StandardError; end

  class << self
    def included(klass)
      PermissionSettings::Patcher.call(klass)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

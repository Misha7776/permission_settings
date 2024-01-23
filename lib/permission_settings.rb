# frozen_string_literal: true

require_relative 'permission_settings/version'
require_relative 'permission_settings/patcher'
require 'byebug'

# Gem entrypoint
module PermissionSettings
  class NotFoundError < StandardError; end

  def self.included(klass)
    PermissionSettings::Patcher.call(klass)
  end
end

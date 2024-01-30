# frozen_string_literal: true

require_relative 'verify'

module PermissionSettings
  # comment
  class VerifyInstance < PermissionSettings::Verify
    def call
      super
      return permission_value unless block_given?

      permission_value && block.call
    end
  end
end

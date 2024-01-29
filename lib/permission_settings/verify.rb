# frozen_string_literal: true

require 'byebug'
require 'active_support/hash_with_indifferent_access'

module PermissionSettings
  class Verify
    def initialize(permission_keys, role, resource, &block)
      @permission_keys = permission_keys.map(&:to_s)
      @role = role
      @resource = resource
      @block = block
      @scope = PermissionSettings.configuration.scope_name(resource.class)
    end

    def self.call(permission_keys = [], role: nil, resource: nil, &block)
      new(permission_keys, role, resource, &block).call
    end

    def call
      extract_permission_value
      raise_not_found_error if permission_value.nil?
    end

    private

    attr_reader :permission_keys, :role, :resource, :block, :permission_value, :scope

    def extract_permission_value
      fetch_record_permission_value
      fetch_default_permissions_value if @permission_value.nil?
    end

    def fetch_record_permission_value
      @permission_value = action_permitted?(*permission_keys,
                                            resource_permissions.presence || default_permissions)
    end

    def fetch_default_permissions_value
      @permission_value = action_permitted?(*permission_keys, default_permissions)
    end

    def action_permitted?(*permission_keys, permissions)
      permissions.dig(role, *permission_keys.reverse)
    end

    def resource_permissions
      ActiveSupport::HashWithIndifferentAccess.new(resource.settings(scope).value)
    end

    def default_permissions
      ActiveSupport::HashWithIndifferentAccess.new(resource.default_settings[scope])
    end

    def raise_not_found_error
      keys = permission_keys.reverse.unshift(role).join('.')
      raise NotFoundError, "You need to set #{keys} permission in #{resource.class} class"
    end
  end
end

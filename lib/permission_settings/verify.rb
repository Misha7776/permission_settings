# frozen_string_literal: true

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
      @permission_value = fetch_permission_value
    end

    def fetch_permission_value
      # If edit permission is requested, access must also be True
      return evaluate_edit_permission_request if edit_request?

      action_permitted?(*permission_keys)
    end

    def evaluate_edit_permission_request
      action_permitted?('access', permission_keys.last) && action_permitted?(*permission_keys)
    end

    def edit_request?
      permission_keys.include?('edit')
    end

    def action_permitted?(*setting_keys)
      stored_permissions.dig(role, *setting_keys.reverse)
    end

    def stored_permissions
      @stored_permissions ||= resource_permissions
    end

    def resource_permissions
      ActiveSupport::HashWithIndifferentAccess.new(fetch_permissions)
    end

    def fetch_permissions
      resource.settings(scope).value.presence || resource.default_settings[scope]
    end

    def raise_not_found_error
      keys = permission_keys.reverse.unshift(role).join('.')
      raise NotFoundError, "You need to set #{keys} permission in #{resource.class} class"
    end
  end
end

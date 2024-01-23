# frozen_string_literal: true

require_relative 'verify'

module PermissionSettings
  # comment
  class VerifyCollection < PermissionSettings::Verify
    def initialize(collection, keys, role, resource)
      super(keys, role, resource)
      @collection = collection
    end

    def self.call(collection, keys, role, resource: nil)
      new(collection, keys, role, resource).call
    end

    def call
      super
      return collection if permission_value

      filter_out_collection
    end

    private

    attr_reader :collection, :roles

    def filter_out_collection
      collection.where.not(role: role)
    end
  end
end

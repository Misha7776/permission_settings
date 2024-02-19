# frozen_string_literal: true

# require 'byebug'

module PermissionSettings
  class Configuration
    class PermissionsDirNotFound < StandardError; end

    DEFAULT_PERMISSION_FILE_PATH = 'config/permissions'
    DEFAULT_ROLE_ACCESS_METHOD = :role

    attr_accessor :role_access_method
    attr_reader :permissions_dir_path

    def initialize
      @permissions_dir_path = DEFAULT_PERMISSION_FILE_PATH
      @role_access_method = DEFAULT_ROLE_ACCESS_METHOD
    end

    def permissions_dir_path=(path)
      raise PermissionsDirNotFound, 'Permissions directory not found' unless Dir.exist?(path)

      @permissions_dir_path = path
    end

    def scope_name(klass)
      [klass.name.underscore, 'permissions'].join('_').to_sym
    end

    def load_permissions_file(klass)
      if RUBY_VERSION.to_f >= 3.1
        YAML.load_file(permission_file_path(klass), aliases: true)
      else
        YAML.load_file(permission_file_path(klass))
      end
    end

    def permission_file_path(klass)
      File.join(permissions_dir_path, "#{klass.name.underscore}.yml")
    end
  end
end

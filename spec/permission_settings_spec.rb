# frozen_string_literal: true

require 'byebug'
require_relative 'support/user'

RSpec.describe PermissionSettings do
  it 'has a version number' do
    expect(PermissionSettings::VERSION).not_to be nil
  end

  describe 'included' do
    it 'response to can? method' do
      expect(User.new.respond_to?(:can?)).to be true
    end

    it 'response to has_settings class method' do
      expect(User.respond_to?(:has_settings)).to be true
      expect(User.respond_to?(:default_settings)).to be true
      expect(User.new.respond_to?(:default_settings)).to be true
      expect(User.new.respond_to?(:settings, PermissionSettings.configuration.scope_name(User))).to be true
    end
  end

  describe 'configure' do
    context 'permissions directory path' do
      context 'as default' do
        it 'has permissions_dir_path default configuration' do
          expect(described_class.configuration.permissions_dir_path).to eq PermissionSettings::Configuration::DEFAULT_PERMISSION_FILE_PATH
        end
      end

      context 'as custom' do
        let(:custom_permissions_dir_path) { 'config/custom_permissions/' }

        before do
          described_class.configure do |config|
            config.permissions_dir_path = custom_permissions_dir_path
          end
        end

        it 'has permissions_dir_path custom configuration' do
          expect(described_class.configuration.permissions_dir_path).to eq custom_permissions_dir_path
        end
      end
    end

    context 'role access method' do
      context 'as default' do
        it 'has role_access_method default configuration' do
          expect(described_class.configuration.role_access_method).to eq PermissionSettings::Configuration::DEFAULT_ROLE_ACCESS_METHOD
        end
      end

      context 'as custom' do
        let(:custom_role_access_method) { :custom_role_method }

        before do
          described_class.configure do |config|
            config.role_access_method = custom_role_access_method
          end
        end

        it 'has role_access_method custom configuration' do
          expect(described_class.configuration.role_access_method).to eq custom_role_access_method
        end
      end
    end
  end
end

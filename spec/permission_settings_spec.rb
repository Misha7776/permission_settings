# frozen_string_literal: true

# require 'byebug'
require_relative 'support/user'

RSpec.describe PermissionSettings do
  before do
    User.include(described_class)
  end

  it 'has a version number' do
    expect(PermissionSettings::VERSION).not_to be_nil
  end

  describe 'included' do
    it 'response to can? method' do
      expect(User.new.respond_to?(:can?)).to be true
    end

    it 'response to has_settings class method' do
      expect(User.respond_to?(:has_settings)).to be true
    end

    it 'response to settings instance method' do
      expect(User.new.respond_to?(:settings, described_class.configuration.scope_name(User)))
        .to be true
    end

    it 'response to default_settings instance method' do
      expect(User.new.respond_to?(:default_settings)).to be true
    end

    it 'response to default_settings class method' do
      expect(User.respond_to?(:default_settings)).to be true
    end
  end

  describe 'can?' do
    let(:admin) { User.create(role: :admin) }
    let(:manager) { User.create(role: :manager) }

    context 'when role permissions are present' do
      it 'returns true' do
        expect(admin.can?(:read, :notifications, resource: manager)).to be true
      end

      it 'returns false' do
        expect(manager.can?(:delete, :notifications, resource: admin)).to be false
      end
    end

    context 'when role permissions are not present' do
      it 'returns an error' do
        expect { admin.can?(:edit, :post, resource: manager) }
          .to raise_error(PermissionSettings::NotFoundError)
      end
    end
  end

  describe 'configure permissions directory path' do
    context 'when default' do
      it 'has permissions_dir_path default configuration' do
        expect(described_class.configuration.permissions_dir_path)
          .to eq PermissionSettings::Configuration::DEFAULT_PERMISSION_FILE_PATH
      end
    end

    context 'when custom' do
      let(:custom_permissions_dir_path) { 'config/custom_permissions/' }

      before do
        described_class.configure do |config|
          config.permissions_dir_path = custom_permissions_dir_path
        end
      end

      it 'has permissions_dir_path custom configuration' do
        expect(described_class.configuration.permissions_dir_path)
          .to eq custom_permissions_dir_path
      end
    end

    context 'when permissions directory does not exist' do
      let(:custom_permissions_dir_path) { 'config/super_admin_permissions/' }
      let(:configuration) do
        described_class.configure do |config|
          config.permissions_dir_path = custom_permissions_dir_path
        end
      end

      it 'raises PermissionsDirNotFound error' do
        expect { configuration }.to raise_error(PermissionSettings::Configuration::PermissionsDirNotFound)
      end
    end

    context 'when role access method is default' do
      it 'has role_access_method default configuration' do
        expect(described_class.configuration.role_access_method)
          .to eq PermissionSettings::Configuration::DEFAULT_ROLE_ACCESS_METHOD
      end
    end

    context 'when role access method is custom' do
      let(:custom_role_access_method) { :custom_role_method }

      before do
        described_class.configure do |config|
          config.role_access_method = custom_role_access_method
        end
      end

      it 'has role_access_method custom configuration' do
        expect(described_class.configuration.role_access_method)
          .to eq custom_role_access_method
      end
    end
  end

  describe 'settings' do
    let(:source_class) { User }
    let(:policy_scope) { described_class.configuration.scope_name(source_class) }

    before do
      described_class.configure do |config|
        config.role_access_method = :role
      end
    end

    context 'with custom settings' do
      let(:admin) { source_class.create(role: :admin) }
      let(:client) { source_class.create(role: :client) }
      let(:custom_permissions) do
        { 'admin' => { items: { read: false, create: false },
                       notifications: { read: false },
                       payments: { read: false, create: false } } }
      end

      it 'allows to modify default settings' do
        client.settings(policy_scope).update(custom_permissions)
        setting_object = client.settings(policy_scope)
        expect(setting_object.target).to eq client
        expect(setting_object.value).to eq custom_permissions
      end

      it 'overrides default settings' do
        expect(admin.can?(:read, :notifications, resource: client)).to be true
        client.settings(policy_scope).update(custom_permissions)
        expect(admin.can?(:read, :notifications, resource: client)).to be false
      end

      it 'works with default settings if untouched' do
        expect(admin.can?(:edit, :notifications, resource: client)).to be true
        client.settings(policy_scope).update(custom_permissions)
        expect(admin.can?(:edit, :notifications, resource: client)).to be true
      end

      it 'reverts back to default settings' do
        client.settings(policy_scope).update(custom_permissions)
        expect(admin.can?(:read, :notifications, resource: client)).to be false
        client.settings(policy_scope).update({ admin: { notifications: nil } })
        expect(admin.can?(:read, :notifications, resource: client)).to be true
      end
    end
  end
end

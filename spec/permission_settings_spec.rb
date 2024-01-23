# frozen_string_literal: true

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
    end
  end
end

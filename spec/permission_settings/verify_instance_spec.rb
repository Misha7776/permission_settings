# frozen_string_literal: true

require_relative '../support/user'
require_relative '../../lib/permission_settings'
require 'byebug'

RSpec.describe PermissionSettings::VerifyInstance do
  subject(:response) do |ex|
    described_class.call(ex.metadata[:keys], role: ex.metadata[:role], resource: User.new)
  end

  before do
    User.include(PermissionSettings)
  end

  context 'when role permissions are present' do
    context 'when permission is false', keys: %i[read notifications], role: :admin do
      it 'returns true' do
        expect(response).to be true
      end
    end

    context 'when permission is true', keys: %i[delete payments], role: :manager do
      it 'returns true' do
        expect(response).to be false
      end
    end
  end

  context 'when role permissions are not present' do
    it 'returns an error', keys: %i[read alerts], role: :client do
      expect { response }.to raise_error(PermissionSettings::NotFoundError)
    end
  end
end

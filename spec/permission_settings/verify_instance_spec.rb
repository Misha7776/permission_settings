# frozen_string_literal: true

require_relative '../support/user'
require_relative '../../lib/permission_settings'
require 'byebug'

RSpec.describe PermissionSettings::VerifyInstance do
  subject(:response) do |ex|
    described_class.call(ex.metadata[:keys], role: ex.metadata[:role], resource: User.new)
  end

  context 'when role permissions are present' do
    context 'when permission is false', role: :admin, keys: %i[read notifications] do
      it 'returns true' do
        expect(response).to be true
      end
    end

    context 'when permission is true', role: :manager, keys: %i[delete payments] do
      it 'returns true' do
        expect(response).to be false
      end
    end
  end

  context 'when role permissions are not present' do
    it 'returns an error', role: :client, keys: %i[read alerts] do
      expect { response }.to raise_error(PermissionSettings::NotFoundError)
    end
  end
end

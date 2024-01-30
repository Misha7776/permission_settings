# frozen_string_literal: true

require 'byebug'
require_relative '../support/user'

RSpec.describe PermissionSettings::Patcher do
  let(:source_class) { User }
  let(:policy_scope) { PermissionSettings.configuration.scope_name(source_class) }

  context 'when accepts class' do
    before do
      described_class.call(source_class)
    end

    context 'with default settings' do
      it 'includes default_settings methods' do
        expect(source_class.new.respond_to?(:default_settings)).to be true
      end

      it 'includes settings methods' do
        expect(source_class.new.respond_to?(:settings, policy_scope))
          .to be true
      end

      it 'includes can? instance method' do
        expect(source_class.new.respond_to?(:can?)).to be true
      end
    end
  end
end

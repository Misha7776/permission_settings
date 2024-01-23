# frozen_string_literal: true

require_relative '../../lib/permission_settings/verify'

class User < ActiveRecord::Base
  include PermissionSettings

  has_settings do |s|
    s.key PermissionSettings::Verify::SETTINGS_SCOPE,
          defaults: { client: { alerts: { access: false, edit: false },
                                notifications: { access: true, edit: true },
                                timeline: { access: false, edit: false },
                                charts: { access: false, edit: false },
                                devices: { access: false, edit: false } } }
  end
end

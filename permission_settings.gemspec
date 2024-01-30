# frozen_string_literal: true

require_relative 'lib/permission_settings/version'

Gem::Specification.new do |spec|
  spec.name = 'permission_settings'
  spec.version = PermissionSettings::VERSION
  spec.authors = ['Misha Push']
  spec.email = ['m.push@coaxsoft.com']

  spec.summary = 'Allows to dynamically set, retrieve and check permissions of your resource model'
  spec.homepage = 'https://github.com/Misha7776/permission_settings'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/Misha7776/permission_settings/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'activesupport', '~> 7.0.0'
  spec.add_dependency 'ledermann-rails-settings', '~> 2.6.1'
end

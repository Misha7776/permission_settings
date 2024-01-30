## [Unreleased]

## [0.1.3] - 2024-01-29

- Cover with tests different use cases

## [0.1.2] - 2024-01-25

- Configuration interface.
  - Added `#configure` method to configure: 
    * permissions_dir_path configuration option for setting path to permissions directory
    * role_access_method configuration option for setting method name to access role of the resource instance
  - Added `#has_settings` method to configure dynamic settings.
    It accepts a scope name were the settings will stored under and default settings hash from a yaml file.

## [0.1.1] - 2024-01-23

- Added basic class structure and core logic
- Configured rspec. Covered instance verification logic with specs

## [0.1.0] - 2024-01-17

- Initial release

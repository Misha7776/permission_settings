# PermissionSettings - [Changelog](https://github.com/Misha7776/permission_settings/blob/main/README.md)

**PermissionSettings** allows to dynamically set, retrieve and check permissions of your resource model.
Under the hood it uses **[Rails Settings](https://github.com/ledermann/rails-settings)** gem for storing settings in database.
Main idea is to store permissions in yaml files that can be divided by resource models and roles.
It alos allows to change permissions without restarting the application that gives you more flexibility in build a permissions system.

### Tested with ruby:
- 3.0.2

## Requirements

- Rails 6.1 or newer (including Rails 7.0)

## Installation

Include the gem in your Gemfile and run `bundle` to install it:

```ruby
gem 'permission_settings', '~> 0.1.0'
```

Generate and run the migration to create the settings table that is used to store the permissions:

```shell
rails g rails_settings:migration
rake db:migrate
```

## Usage

### Configuration

You can configure the gem by calling `PermissionSettings.configure` method in an initializer:

```ruby 
# config/initializers/permission_settings.rb

PermissionSettings.configure do |_config|
  config.permissions_dir_path = 'config/permissions'
  config.role_access_method = :role
end
```
* `permissions_dir_path` - configuration option for setting path to permissions directory
* `role_access_method` - configuration option for setting method name to access role of the resource instance

You can create different yaml files for different resource models to keep permissions separated.
by default it looks for yaml files in `config/permissions` directory.

### Permissions file structure

Gem will load permissions from yaml files into database on application start.

The permissions file should be a yaml file and should be the same as the name of the resource model.

For example, if you have a `User` model, you can create a `user.yml` file in `config/permissions` directory with the following structure:

```yaml
# config/permissions/person.yml

admin:
  notifications:
    read: true
    create: true
    edit: true
    delete: true

manager:
  notifications:
    read: true
    create: false
    edit: false
    delete: false
```

In this file we should divided permissions into roles. If not following this structure gem won't find permissions that are defined for a specific role of that calling instance.
If you experience a `PersistentSettings::NotFoundError` error, please check if you have defined permissions for that role inside the permissions file of resource model.

### Connecting permissions to the resource and calling model

To connect permissions to the resource model you need just to include `PersmissionSettings` module in the model class:

Calling model:

```ruby
class User < ApplicationRecord
  include PermissionSettings
end
```

Resource model:

```ruby 
class Person < ApplicationRecord
  include PermissionSettings
end
```

In order to check permissions of the resource instance you need to pass it as a named argument `resource` to the `#can?` method.

Take into account that the resource model should have a `role` filed or method that returns a role name of the calling instance or you can configure the gem to use another method name by setting `role_access_method` configuration option.

### Checking permissions

You can check permissions of the resource instance by calling `#can?` method:

```ruby
user = User.first # => #<User id: 1, name: "John", role: "manager">
person = Person.last # => #<Person id: 2, name: "Jane", role: "client">
user.can?(:read, :notifications, resource: person) # => true
```

Method `can?` accepts 2 arguments:
* `*permission_keys` - this keys will be used to find permissions in the settings. It can be a string or an array of strings. Required argument.
* `*resource` - Named argument resource. Instance towards which the permissions will be checked. Required argument.

### Accessing permissions

You can also access permissions of the resource or calling instance by calling `#settings` method:

```ruby
person = Person.last # => #<Person id: 2, name: "Jane", role: "client">
person.settings[PermissionSettings.configuration.scope_name].admin.notifications.read # => false
```

More about settings you can read in [Rails Settings](https://github.com/ledermann/rails-settings) gem documentation.

### Dynamic settings

You can override default settings by calling `#has_settings` method in the resource model class:

```ruby
custom_permissions = {
  admin: {
    notifications: {
      read: false,
      create: false,
      edit: false,
      delete: false
    }
  }
}
admin = User.first # => #<User id: 1, name: "John", role: "admin">
person = Person.last # => #<User id: 2, name: "Jane", role: "client">

admin.can?(:read, :notifications, resource: person) # => true

person.settings(PermissionSettings.configuration.scope_name).update(custom_permissions)

admin.can?(:read, :notifications, resource: person) # => false
```

If you will unset your custom settings, default settings will be used:

```ruby
custom_permissions = {
  admin: {
    notifications: {
      read: false,
      create: false,
      edit: false,
      delete: false
    }
  }
}

admin = User.first # => #<User id: 1, name: "John", role: "admin">
person = Person.last # => #<User id: 2, name: "Jane", role: "client">

person.settings(PermissionSettings.configuration.scope_name).update(custom_permissions)

admin.can?(:read, :notifications, resource: person) # => false

person.settings(policy_scope).update({ admin: { notifications: nil } })

admin.can?(:read, :notifications, resource: person) # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [Permission Settings](https://github.com/Misha7776/permission_settings). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Misha7776/permission_settings/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PermissionSettings project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/permission_settings/blob/main/CODE_OF_CONDUCT.md).

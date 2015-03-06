require 'rails/generators/active_record'

class CapableGenerator < Rails::Generators::Base

  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  # Implement the required interface for Rails::Generators::Migration.
  def self.next_migration_number(dirname) #:nodoc:
    next_migration_number = current_migration_number(dirname) + 1
    if ActiveRecord::Base.timestamped_migrations
      [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
    else
      "%.3d" % next_migration_number
    end
  end

  def create_capable_migration
    migration_template 'migration.rb', File.join('db', 'migrate', 'capable_migration.rb')
  end

  def move_ability_model
    template 'ability.rb', File.join('app', 'models', 'ability.rb')
  end

  def move_capability_model
    template 'capability.rb', File.join('app', 'models', 'capability.rb')
  end

end

require 'capable'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'

config = {
  :database => 'device_token_test',
  :username => 'test'
}

case ENV['DB']
  when 'mysql'
    config = {
      :adapter => 'mysql2',
      :database => 'device_token_test',
      :username => 'test',
      :password => 'test',
      :socket => '/tmp/mysql.sock'
    }
    if ENV['TRAVIS']
      config = {
        :adapter => 'mysql2',
        :database => 'device_token_test',
        :username => 'root'
      }
    end
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.drop_database(config[:database]) rescue nil
    ActiveRecord::Base.connection.create_database(config[:database])
  when 'postgres'
    config = {
      :adapter => 'postgresql',
      :database => 'device_token_test',
      :username => 'test',
    }
    if ENV['TRAVIS']
      config = {
        :adapter => 'postgresql',
        :database => 'device_token_test',
        :username => 'postgres',
      }
    end
    ActiveRecord::Base.establish_connection(config.merge({ :database => 'postgres' }))
    ActiveRecord::Base.connection.drop_database(config[:database])
    ActiveRecord::Base.connection.create_database(config[:database])
  when 'sqlite3'
    config = {
      :adapter => 'sqlite3',
      :database => 'test.sqlite3',
      :username => 'test',
    }
end

ActiveRecord::Base.establish_connection(config)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do

  create_table :abilities, :force => true do |t|
    t.string :ability, :null => false
    t.string :name, :null => false
    t.string :description, :null => false
    t.timestamps
  end

  create_table :capabilities, :force => true do |t|
    t.integer :ability_id, :null => false
    t.references :capable, :polymorphic => true, :null => false
    t.references :renewer, :polymorphic => true
    t.boolean :active, :default => true
    t.datetime :expires_at, :null => true
    t.timestamps
  end

  create_table :users, :force => true do |t|
    t.string :name
    t.string :ability_list
    t.timestamps
  end

  create_table :non_cached_users, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :renewers, :force => true do |t|
    t.timestamps
  end

end

class Ability < ActiveRecord::Base
  acts_as_ability
end

class Capability < ActiveRecord::Base
  acts_as_capability
end

class User < ActiveRecord::Base
  acts_as_capable
end

class NonCachedUser < ActiveRecord::Base
  acts_as_capable
end

class Renewer < ActiveRecord::Base
  acts_as_capability_renewer
end

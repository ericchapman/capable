class CapableMigration < ActiveRecord::Migration
  def self.up

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

    add_index :capabilities, [:active, :expires_at]
    add_index :capabilities, [:capable_id, :capable_type, :active]
    add_index :capabilities, [:capable_id, :capable_type, :ability_id, :renewer_id, :renewer_type], :name => 'capabilities_all_index'

  end

  def self.down

    drop_table :abilities
    drop_table :capabilities

  end

end

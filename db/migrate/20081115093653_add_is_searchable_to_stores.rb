class AddIsSearchableToStores < ActiveRecord::Migration
  def self.up
    add_column :stores, :is_searchable, :boolean, :default=>false
  end

  def self.down
    remove_column :stores, :is_searchable
  end
end

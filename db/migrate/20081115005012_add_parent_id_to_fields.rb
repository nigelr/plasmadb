class AddParentIdToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :parent_id, :integer
  end

  def self.down
    remove_column :fields, :parent_id
  end
end

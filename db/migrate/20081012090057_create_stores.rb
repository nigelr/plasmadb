class CreateStores < ActiveRecord::Migration
  def self.up
    create_table :stores do |t|
      t.references :doc
      t.references :field
      t.string :data, :limit => 10000
      t.integer :rev, :default=>0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :stores
  end
end

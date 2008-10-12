class CreateStores < ActiveRecord::Migration
  def self.up
    create_table :stores do |t|
      t.references :doc
      t.references :field
      t.string :data, :limit => 10000

      t.timestamps
    end
  end

  def self.down
    drop_table :stores
  end
end

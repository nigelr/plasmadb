class CreateFields < ActiveRecord::Migration
  def self.up
    create_table :fields do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :fields
  end
end

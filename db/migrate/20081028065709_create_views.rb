class CreateViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.references :field
      t.string :block_code

      t.timestamps
    end
  end

  def self.down
    drop_table :views
  end
end

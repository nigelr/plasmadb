class AddArchivedAtToDoc < ActiveRecord::Migration
  def self.up
    add_column :docs, :archived_at, :datetime
  end

  def self.down
    remove_column :docs, :archived_at
  end
end

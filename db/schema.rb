# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081122110526) do

  create_table "docs", :force => true do |t|
    t.integer  "rev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "archived_at"
  end

  create_table "fields", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  create_table "stores", :force => true do |t|
    t.integer  "doc_id"
    t.integer  "field_id"
    t.string   "data_item",     :limit => 10000
    t.integer  "rev",                            :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_searchable",                  :default => false
  end

  create_table "views", :force => true do |t|
    t.integer  "field_id"
    t.string   "block_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

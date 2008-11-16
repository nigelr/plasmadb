class Field < ActiveRecord::Base
  has_many :stores
  has_many :docs, :through => :stores
  has_one :view
  belongs_to :parent, :class_name=>"Field", :foreign_key=>"parent_id"
  has_many :children, :class_name=>"Field", :foreign_key=>"parent_id"
  
  named_scope :active_fields, {
    :conditions => ["stores.rev = ?", 0],
    :include => :stores
  }


end

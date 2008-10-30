class Field < ActiveRecord::Base
  has_many :stores
  has_many :docs, :through => :stores
  has_one :view
  
  named_scope :active_fields, {
    :conditions => ["stores.rev = ?", 0],
    :include => :stores
  }


end

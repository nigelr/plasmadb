class Field < ActiveRecord::Base
  has_many :stores
  has_many :docs, :through => :stores


  def store(doc_id)
    stores.find_by_doc_id(doc_id)
  end

end

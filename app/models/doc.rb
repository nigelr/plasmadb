class Doc < ActiveRecord::Base
  has_many :stores
  has_many :fields, :through => :stores

  def self.retrieve id
    docs = self.find(id, :include=>:fields)
    id.is_a?(Array) ? docs.inject([]) {|build, doc| build << doc.retrieve} : docs.retrieve
  end

  def self.store items
    if items.is_a? Hash
      doc = self.find_or_create_by_id(items[:_id], :include=>:fields)
      doc.store_items items
    end
  end


  # search Document
  #
  # ==== Parameters
  # :fields
  # :operand defaults to ==
  # :value
  # :operator
  #   == default
  #   >
  #   <
  #   >=
  #   <=
  #   !=
  #   * contains
  #   ^ begins
  #   $ ends
  #
  def self.search value, options={}
    res = Store.include_fields(options[:fields]).search_for(value, options[:operator]).find(:all, :select=>:doc_id)
    res.map {|store| store.doc_id}
  end


  def retrieve
    stores.inject({:_id=>self.id}) {|build, store| build.merge!(store.field.name.to_sym=>store.data)}
  end
  
  def store_items items
    delete_old_items items
    update_items items
    retrieve
  end

  def delete_old_items items
    data_keys = items.keys
    for field in fields
      unless data_keys.include?(field.name.to_sym)
        field.store(id).destroy
        field.destroy if field.stores.count == 0
      end
    end
  end

  def update_items items
    for field_name, item in items
      unless field_name.to_s == "_id"
        field = Field.find_or_create_by_name(field_name.to_s)
        stores.find_or_create_by_field_id_and_data(field.id, item)
      end
    end
  end

end

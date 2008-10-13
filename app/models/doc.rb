class Doc < ActiveRecord::Base
  has_many :stores, :conditions => 'stores.version is null'
#  has_many :all_stores,
#    :class_name => "Store",
#    :foreign_key => "doc_id"
  has_many :fields, :through => :stores

  def self.retrieve id, options={}
    docs = self.find(id)
    id.is_a?(Array) ? docs.inject([]) {|build, doc| build << doc.retrieve} : docs.retrieve(options[:rev])
  end

  def self.store items
    if items.is_a? Hash
      doc = self.find_or_create_by_id(items[:_id])
      #      puts "doc.rev.to_i+1=#{doc.rev}"
      doc.store_items items
      doc.update_attribute(:rev, doc.rev.to_i+1)
      doc.retrieve

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


  def retrieve(rev=nil)
    stores.revision(rev).inject({:_id=>self.id, :_rev => self.rev, }) {|build, store| build.merge!(store.field.name.to_sym=>store.data)}
  end
  
  def store_items items
    #    delete_old_items items
    update_items items
  end

  #  def delete_old_items items
  #    data_keys = items.keys
  #    for field in fields
  #      unless data_keys.include?(field.name.to_sym)
  #        field.store(id).destroy
  #        field.destroy if field.stores.count == 0
  #      end
  #    end
  #  end

  def update_items items
    stores.update_all("version=#{rev}")
    for field_name, item in items
      unless field_name.to_s == "_id" or field_name.to_s == "_rev"
        field = Field.find_or_create_by_name(field_name.to_s)
        stores.create(:field => field, :data => item, :version => nil)
      end
    end
  end

end

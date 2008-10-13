class Doc < ActiveRecord::Base
  has_many :stores 
  has_many :fields, :through => :stores, :conditions=>["rev = ?", 0]

  def self.retrieve id, options={}
    docs = self.find(id)
    id.is_a?(Array) ? docs.inject([]) {|build, doc| build << doc.retrieve} : docs.retrieve(options[:rev]||0)
  end

  def self.store items
    if items.is_a? Hash
      doc = self.find_or_create_by_id(items[:_id])
      unless doc.rev == items[:_rev]
        raise "Update failed: due to out of date revision number"
      else
        #      puts "doc.rev.to_i+1=#{doc.rev}"
        doc.store_items items
        doc.update_attribute(:rev, doc.rev.to_i+1)
        doc.retrieve
      end

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
  # :rev revision to search (:all, :history, :current (default) or revision number)
  #
  #
  def self.search value, options={}
    res = Store.include_fields(options[:fields]).search_for(value, options[:operator]).revision(options[:rev]).find(:all, :select=>:doc_id)
    res.map {|store| store.doc_id}
  end


  def retrieve(rev=0)
    stores.revision(rev).inject({:_id=>self.id, :_rev => (rev.to_i==0 ? self.rev : rev) }) {|build, store| build.merge!(store.field.name.to_sym=>store.data)}
  end
  
  def store_items items
    stores.revision(nil).update_all(:rev=>rev)
    for field_name, item in items
      unless field_name.to_s == "_id" or field_name.to_s == "_rev"
        field = Field.find_or_create_by_name(field_name.to_s)
        stores.create(:field => field, :data => item, :rev => 0)
      end
    end
  end

end

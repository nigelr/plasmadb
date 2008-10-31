class Doc < ActiveRecord::Base
  has_many :stores 
  has_many :fields, :through => :stores, :conditions=>["rev = ?", 0]

  # Retrieve document by id(s)
  #
  # ==== Parameters
  # * id - Either a
  # *    :all
  # *    single id
  # *    array of ids
  # * options:
  # *  :rev Revion of document to return
  #   
  # ==== Returns
  # * document if single id
  # * array of documents if array of id(s)
  # * nil if none found
  #
  def self.retrieve id, options={}
    if id == :all
      docs = self.find(:all)
    else
      docs = self.find_all_by_id(id)
    end
    unless docs.empty?
     res = (id.is_a?(Array) or id == :all) ? docs.inject([]) {|build, doc| build << doc.retrieve} : docs.first.retrieve(options[:rev]||0)
#     a = docs.map {|doc| doc.retrieve} #: docs.first.retrieve(options[:rev]||0)
    end
    return res
  end

  # Stores or updates a document into the database
  #
  # ==== Parameters
  #
  # * items - hash of items
  # 
  # * If no :_id field is supplied than document is added as a new record
  #
  # * When and :_id record is supplied a :_rev is also needed
  # * if :_rev does not mathch rev in database, then save will fail as the
  #   record has been updated by another person
  #
  # ==== Returns
  # ===== Success
  # Existing or new docuemnt (including :_id and :_rev)
  # ===== Failure
  # nil - nothing added
  # false - nothing added and revision failed
  #
  def self.store items
    if items.is_a? Hash
      doc = self.find_or_create_by_id(items[:_id])
      return false unless doc.rev == items[:_rev]

      doc.store_items items
      doc.update_attribute(:rev, doc.rev.to_i+1)
      return doc.retrieve
    else
      return nil
    end
  end


  # search Document
  #
  # ==== Parameters
  # * value
  # * options:
  # *  fields - List of field names to search on (if left blank then all)
  # *  operator
  #     "==" (default), ">", "<", ">=", "<=", "!=", "*" contains, "^" begins, "$" ends
  # *  rev - revision to search (:all, :history, :current (default) or revision number)
  # *  ids - list of document ids to search (if left blank then all ids)
  #
  # ==== Returns
  # * Array of document ids
  #
  def self.search value, options={}
    res = Store.include_fields(options[:fields]).search_for(value, options[:operator]).revision(options[:rev]).filter_on_ids(options[:ids]).find(:all, :select=>:doc_id)
    res.map {|store| store.doc_id}
  end


  def retrieve(rev=0) # :nodoc:
    stores.revision(rev).inject({:_id=>self.id, :_rev => (rev.to_i==0 ? self.rev : rev) }) {|build, store| build.merge!(store.field.name.to_sym=>store.data)}
  end
  
  def store_items items # :nodoc:
    stores.revision(nil).update_all(:rev=>rev)
    for field_name, value in items
      field_name = field_name.to_s
      unless field_name == "_id" or field_name == "_rev"
        store_data field_name, value
      end
    end

#    build_it items

  end

  def store_data field_name, value
    field = Field.find_or_create_by_name(field_name)
    stores.create(:field => field, :data => value, :rev => 0)
  end


  def build_it args
    for view in View.all
      build_view_data view.field.name do
        eval view.block_code
      end
    end
  end

  def build_view_data view_name, default_value = nil
    view_name = "_" + view_name.to_s
    begin
      store_data view_name, yield
    end
  end

end

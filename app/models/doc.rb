class Doc < ActiveRecord::Base
  has_many :stores 
  has_many :fields, :through => :stores, :conditions=>["rev = ?", 0]

  # Retrieve document by id(s)
  #
  # ==== Parameters
  # * id 
  # *    :all, :first, :last
  # *    single id
  # *    array of ids
  # * options:
  # *  :rev Revion of document to return (supported for singular lookup only)
  #   
  # ==== Returns
  # * document if single id
  # * array of documents if array of id(s)
  # * nil if none found
  #
  def self.retrieve id, options={}
    with_scope(:find=>{:conditions=>{:archived_at=>nil}}) do
      validate_options(options, [:rev])
      case id
      when Symbol
        if id == :all
          docs = self.find(id)
        else
          docs = [self.find(id)]
        end
      else
        docs = self.find_all_by_id(id)
      end
      unless docs.empty?
        res = (id.is_a?(Array) or id == :all) ? docs.map {|doc| doc.retrieve} : docs.first.retrieve(options[:rev]||0)
        #     a = docs.map {|doc| doc.retrieve} #: docs.first.retrieve(options[:rev]||0)
      end
      return res
    end
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
  # *  supports singular, array and nesting of fields such as:
  # *  :fields => :first_name
  # *  :fields => [:first_name, :last_name]
  # *  :fields => {:phone_numbers => :mobile}
  # *  :fields => {:phone_numbers => {:fax => [:free_call, :local]}}
  # *  :fields => {:phone_numbers => "*"} -> returns all children fields under :phone_numbers
  # 
  # *  operator
  #     "==" (default), ">", "<", ">=", "<=", "!=", "*" contains, "^" begins, "$" ends
  # *  rev - revision to search (:all, :history, :current (default) or revision number)
  # *  ids - list of document ids to search (if left blank then all ids)
  #
  # ==== Returns
  # * Array of document ids
  #
  def self.search value, options={}
    validate_options(options, [:fields, :rev, :ids, :operator])
    res = Store.include_fields(options[:fields]).
      search_for(value, options[:operator]).
      revision(options[:rev]).
      filter_on_ids(options[:ids]).
      is_searchable(value).
      find(:all, :select=>:doc_id)

    res.map {|store| store.doc_id}
  end


  # Remove document by id(s)
  #
  # ==== Parameters
  # * id
  # *    single id
  # *    array of ids
  # * options:
  # *  TBA
  #
  # ==== Returns
  # * array of document id(s) removed
  # * nil if none found
  #
  # ===== Note
  # This is not a delete, it changes the document stores revision to previous number so it is no longer active
  #
  def self.remove id, options=nil
    ret = []
    for doc in find_all_by_id(id)
      doc.remove
      ret << doc.id
    end
    ret.empty? ? nil : ret
  end

  def remove # :nodoc:
    stores.update_all({:rev=>rev}, {:rev=>0})
    update_attribute(:archived_at, Time.now)
  end

  def retrieve(revision=0) # :nodoc:
    revision = 0 if revision == self.rev

    stores.revision(revision).top_level_fields.inject(
      {:_id=>self.id, :_rev => (revision.to_i==0 ? self.rev : revision) }) do |build, store|
      build.merge!(store.field.name.to_sym=>store.data)
    end
  end

  def store_items items # :nodoc:
    stores.revision(nil).update_all(:rev=>rev)
    for field_name, value in items
      unless field_name == :_id or field_name == :_rev
        store_data field_name, value
      end
    end
  end

  def store_data field_name, value, parent_field=nil # :nodoc:
    field_name = field_name.to_s
    field = Field.find_or_create_by_name_and_parent_id(field_name, parent_field.nil? ? nil : parent_field.id)
    is_searchable = true
    if value.is_a? Hash
      is_searchable = false
      for hash_field_name, hash_value in value
        store_data hash_field_name, hash_value, field
      end
    end
    if value.is_a? Array
      is_searchable = false
      for array_value in value
        store_data field.name, array_value, field
      end

    end
    #    else # add this if decide to prevent duplication of data
    stores.create(:field => field, :data => value, :rev => 0, :is_searchable=> is_searchable) # change is_child to is_hash in table
    #    end
  end

  def self.validate_options(options, valid_options) # :nodoc:
    invalid_options = (options.keys - valid_options)
    raise "Invalid option(s) of #{invalid_options.join(", ")}" unless invalid_options.empty?
  end



end

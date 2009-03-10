require "yaml"  
class Store < ActiveRecord::Base
  belongs_to :doc
  belongs_to :field

#  serialize :data

  MAX_ITEM_SIZE = 10000

  named_scope :top_level_fields, :conditions => "fields.parent_id is null", :include=>"field"
  #  named_scope :top_level_fields, :conditions => {:is_child=>false}
  #  named_scope :is_searchable, :conditions => {:is_searchable=>true}
  named_scope :is_searchable, lambda { |value|
    is_compound = value.is_a?( Hash) || value.is_a?( Array)
    #    puts "is_compound=#{is_compound.inspect}"
    #    puts "value=#{value.class}"
    {
      :conditions => {:is_searchable=>!is_compound}
    }

  }

  named_scope :revision, lambda { |*rev|
    rev = rev.empty? ? 0 : rev.first
    
    {:conditions =>case rev
      when :all
        nil
      when :history
        ["rev != ?", 0]
      else # :current
        {:rev=>rev||0}
      end
    }
  }



  named_scope :include_fields, lambda {|fields|


    if fields.nil? 
      condition = nil
    else
      field_ids = extract_all_fields(fields)
      condition = {:field_id=>field_ids}
    end
    { :conditions=>condition }
  }

  named_scope :search_for, lambda {|value, operator|

    value = case value
    when Hash, Array
      value.to_yaml
    else
      value.to_s
    end

    condition = case operator
    when ">"
      ["data > ?", value]
    when "<"
      ["data < ?", value]
    when ">="
      ["data >= ?", value]
    when "<="
      ["data <= ?", value]
    when "!="
      ["data != ?", value]
    when "*"
      ["data like ?", "%"+value.to_s+"%"]
    when "^"
      ["data like ?", "%"+value.to_s]
    when "$"
      ["data like ?", value.to_s+"%"]
    else # = or ==
      {:data=>value}
    end
    {:conditions => condition}
  }


  named_scope :filter_on_ids, lambda {|*ids|
    #    puts ids.inspect
    {:conditions=>( ids.empty? || ids.first.nil? ? nil :  {:doc_id=>ids.flatten})}
  }

  def self.extract_all_fields field_names, parent_field_id=nil # :nodoc:
    field_ids = []
    field_names = [field_names].flatten
    for field_name in field_names
      if field_name.is_a? Hash
        for hash_field, hash_value in field_name
          field_id = Field.find_by_name_and_parent_id(hash_field.to_s, parent_field_id)
          field_ids += extract_all_fields(hash_value, field_id)
        end
      elsif field_name == "*"
        field_ids += Field.find_all_by_parent_id(parent_field_id)
      else
        field  = Field.find_by_name_and_parent_id(field_name.to_s, parent_field_id) #map {|field| field.id}
        field_ids << field.id if field
      end
    end
    field_ids
  end


  def data
    puts "hello"
    puts data_item.inspect
    YAML.load data_item
  end

  def data=(value)
    data_item = value.to_yaml
  end

end


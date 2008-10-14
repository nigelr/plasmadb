class Store < ActiveRecord::Base
  belongs_to :doc
  belongs_to :field

  MAX_ITEM_SIZE = 10000

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
      field_names = [fields].flatten.map {|field_name| field_name.to_s}
      field_ids = Field.find_all_by_name(field_names).map {|field| field.id}
      condition = {:field_id=>field_ids}
    end
    { :conditions=>condition }
  }

  named_scope :search_for, lambda {|value, operator|
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
  
end


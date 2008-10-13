class Store < ActiveRecord::Base
  belongs_to :doc
  belongs_to :field

  named_scope :revision, lambda { |*rev|

    rev = rev.empty? ? 0 : rev.first
    condition = case rev
    when :all
      nil
    when :history
      ["rev != ?", 0]
    else # :current
      {:rev=>rev||0}
    end
    {:conditions =>condition}
  }

  named_scope :include_fields, lambda {|fields|
    if fields.nil? 
      condition = nil
    else
      # TODO optimize this....
      field_ids = [fields].flatten.map do |field_name|
        field = Field.find_by_name(field_name.to_s)
        field.id if field
      end
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

  
end


class Store < ActiveRecord::Base
  belongs_to :doc
  belongs_to :field

  named_scope :include_fields, lambda {|fields|


    if fields.nil? 
      condition = nil
    else
      field_ids = [fields].flatten.map do |field_name|
        field = Field.find_by_name(field_name.to_s)
        field.id if field
      end
      condition = {:field_id=>field_ids}
    end
    { :conditions=>condition }
  }

  named_scope :search_for, lambda {|value, operator|
    case operator
    when ">"
      condition = ["data > ?", value]
    when "<"
      condition = ["data < ?", value]
    when ">="
      condition = ["data >= ?", value]
    when "<="
      condition = ["data <= ?", value]
    when "!="
      condition = ["data != ?", value]
    when "*"
      condition = ["data like ?", "%"+value.to_s+"%"]
    when "^"
      condition = ["data like ?", "%"+value.to_s]
    when "$"
      condition = ["data like ?", value.to_s+"%"]
    else
      condition ={:data=>value}
    end
    {:conditions => condition}
  }




end


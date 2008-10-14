require 'test_helper'

class FieldTest < ActiveSupport::TestCase

  def test_active_fields
    ret = Field.active_fields
    assert_equal(Field.find(:all, :include=>:stores, :conditions=>"stores.rev=0"), ret)
  end

end

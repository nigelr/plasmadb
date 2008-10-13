require 'test_helper'

class StoreTest < ActiveSupport::TestCase

  def test_revision
    assert_equal Store.find_all_by_rev(0), Store.revision
    assert_equal Store.find_all_by_rev(0), Store.revision(nil)
    assert_equal Store.find_all_by_rev(1), Store.revision(1)
    assert_equal Store.find(:all, :conditions=>"rev != 0"), Store.revision(:history)
    assert_equal Store.all, Store.revision(:all)
  end

  def test_include_fields
    field_1 = fields(:field_1)
    field_2 = fields(:field_2)
    assert_equal Store.all, Store.include_fields(nil)
    assert_equal Store.find_all_by_field_id(field_1.id), Store.include_fields(field_1.name.to_sym)
    assert_equal Store.find_all_by_field_id([field_1.id, field_2.id]), Store.include_fields([field_1.name.to_sym, field_2.name.to_sym])
    assert_equal Store.find_all_by_field_id([field_1.id, field_2.id]), Store.include_fields([field_1.name.to_sym, field_2.name.to_sym])
    assert_equal Store.find_all_by_field_id([field_1.id, field_2.id]), Store.include_fields([field_1.name.to_sym, field_2.name.to_sym])
  end

  # TODO complete this
  def test_search_for

    assert_equal Store.find_all_by_data("barneyb"), Store.search_for("barneyb", nil)
    assert_equal Store.find_all_by_data("barneyb"), Store.search_for("barneyb", "=")
    assert_equal Store.find(:all, :conditions=>"data != 'barneyb'"), Store.search_for("barneyb", "!=")

  end

end

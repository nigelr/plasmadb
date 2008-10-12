require 'test_helper'

class DocTest < ActiveSupport::TestCase

  def test_retrieve
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    assert_equal({:_id=>451413161, :password=>"big_rock", :user_name=>"fredf"}, res)
  end

  def test_retrieve_multiple
    doc = [docs(:doc_1).id, docs(:doc_2).id]
    res = Doc.retrieve(doc)
    assert(res.include?({:_id=>451413161, :password=>"big_rock", :user_name=>"fredf"}))
    assert(res.include?({:age=>"25", :_id=>451413160, :password=>"barneys_password", :user_name=>"barneyb", :name=>"Barney Rubble"}))
    assert res
    assert_equal(res.length, 2)
    puts res.inspect
  end

  def test_update
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    res[:password] = "god"

    doc1 = Doc.store(res)
    assert_equal({:_id=>451413161, :password=>"god", :user_name=>"fredf"}, doc1)
  end

  def test_update_and_removes_document_item
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    res.delete :password

    assert_no_difference("Field.count") do
      assert_difference("Store.count", -1) do
        doc1 = Doc.store(res)
        assert_equal({:_id=>451413161, :user_name=>"fredf"}, doc1)
      end
    end
  end

  def test_update_and_removes_a_document_item_and_a_field
    docs(:doc_2).stores.destroy_all

    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    res.delete :password

    assert_difference("Field.count", -1) do
      assert_difference("Store.count", -1) do
        doc1 = Doc.store(res)
        assert_equal({:_id=>451413161, :user_name=>"fredf"}, doc1)
      end
    end
  end


  def test_insert_new
    assert_difference("Doc.count") do
      assert_difference("Store.count") do
        assert_no_difference("Field.count") do
          doc = Doc.store({:user_name=>"noob"})
          assert_equal({:_id=>Doc.last.id, :user_name=>"noob"}, doc)
        end
      end
    end
  end

  def test_insert_new_with_new_field
    assert_difference("Doc.count") do
      assert_difference("Store.count") do
        assert_difference("Field.count") do
          doc = Doc.store({:a_new_field=>"noob"})
          assert_equal({:_id=>Doc.last.id, :a_new_field=>"noob"}, doc)
        end
      end
    end
  end

  def test_search
    doc_2 = docs(:doc_2)

    ret = Doc.search("barneyb")
    assert ret
    assert_equal(1, ret.length)
    assert_equal(doc_2.id, ret.first)

    ret = Doc.search("barneyb", :fields=>:user_name)
    assert ret

    ret = Doc.search("barneyb", :fields=>[:user_name, :password])
    assert ret

    ret = Doc.search("barneyb", :fields=>:password)
    assert_equal([], ret)

    ret = Doc.search("barneyb", :fields=>:user_name)
    assert ret

    
  end
  
end

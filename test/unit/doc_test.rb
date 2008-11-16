require 'test_helper'

class DocTest < ActiveSupport::TestCase
  # Retrieval
  def test_retrieve_all
    res = Doc.retrieve :all
    assert_equal Doc.count, res.length
  end

  def test_retrieve_first
    res = Doc.retrieve :first
    assert_equal(res[:_id], Doc.first.id)
  end

  def test_retrieve_last
    res = Doc.retrieve :last
    assert_equal(res[:_id], Doc.last.id)
  end

  def test_retrieve
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    assert_equal({:_id=>451413161, :user_name=>"nothing", :_rev=>2}, res)
  end

  def test_retrieve_of_older_revision
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id, :rev=>1)
    assert_equal({:_id=>451413161, :password=>"big_rock", :user_name=>"fredf", :_rev=>1}, res)
  end

  def test_retrieve_of_current_id_when_id_is_specified
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id, :rev=>2)
    assert_equal({:_id=>451413161, :user_name=>"nothing", :_rev=>2}, res)
  end

  def test_retrieve_multiple
    doc_ids = [docs(:doc_1).id, docs(:doc_2).id]
    res = Doc.retrieve(doc_ids)

    assert_equal(res.length, 2)
    #    puts res.inspect
    assert res.include?({:hobbies=>["flinstone", 25] ,:password=>"barneys_password", :age=>25, :name=>"Barney Rubble", :_id=>451413160, :user_name=>"barneyb", :_rev=>1})
    assert res.include?({:_id=>451413161, :user_name=>"nothing", :_rev=>2})
  end

  def test_retrieve_when_id_does_not_exist
    id = Doc.last.id + 1

    assert_nil Doc.retrieve( id)
    assert_nil Doc.retrieve([id,id+1])
  end


  # Update
  def test_update
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    res[:password] = "god"

    doc1 = Doc.store(res)
    assert_equal({:_id=>451413161, :_rev=>3, :password=>"god", :user_name=>"nothing"}, doc1)
  end

  def test_update_should_fail_if_rev_changed
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id, :rev=>1)
    res[:password] = "god"
    #    assert_raise(RuntimeError) do
    doc1 = Doc.store(res)
    assert_equal(false, doc1)
    #    end
  end

  def test_update_and_removes_document_item
    doc = docs(:doc_1)
    res = Doc.retrieve(doc.id)
    res.delete :password

    assert_no_difference("Field.count") do
      assert_difference("Store.count") do
        doc1 = Doc.store(res)
        assert_equal({:_id=>451413161, :user_name=>"nothing", :_rev=>3}, doc1)
      end
    end
  end

  # Insert
  def test_insert_new
    assert_difference("Doc.count") do
      assert_difference("Store.count") do
        assert_no_difference("Field.count") do
          doc = Doc.store({:user_name=>"noob"})
          assert_equal({:_id=>Doc.last.id, :user_name=>"noob", :_rev => 1}, doc)
        end
      end
    end
  end

  def test_insert_new_with_new_field
    assert_difference("Doc.count") do
      assert_difference("Store.count") do
        assert_difference("Field.count") do
          doc = Doc.store({:a_new_field=>"noob"})
          assert_equal({:_id=>Doc.last.id, :a_new_field=>"noob", :_rev=>1}, doc)
        end
      end
    end
  end

  def test_insert_with_a_hash_value
    value = {:a1=>{:b1=>1, :c1=>2, :d1=>{:e1=>3}} }
    assert_difference("Store.count", 5) do
      assert_difference("Field.count", 5) do
        doc = Doc.store(value)
#        puts doc.inspect
      end
    end
    a = Field.find_by_name("a1")
    b = Field.find_by_name("b1")
    c = Field.find_by_name("c1")
    d = Field.find_by_name("d1")
    e = Field.find_by_name("e1")

    assert_nil a.parent_id
    assert_equal a.id, b.parent_id
    assert_equal a.id, c.parent_id
    assert_equal a.id, d.parent_id
    assert_equal d.id, e.parent_id

    #    doc.delete(:_id)
    #    doc.delete(:_rev)
    #    assert_equal(value, doc)
  end

  # search
  def test_search
    # TODO Add more tests and test results more 
    doc_2 = docs(:doc_2)

    ret = Doc.search("barneyb")
    assert ret  
    assert_equal(1, ret.length)
    assert_equal(doc_2.id, ret.first)

    ret = Doc.search("barneyb", :fields=>:user_name)
    assert !ret.empty?

    ret = Doc.search("barneyb", :fields=>[:user_name, :password])
    assert !ret.empty?

    ret = Doc.search("barneyb", :fields=>:password)
    assert ret.empty?

    ret = Doc.search("barneyb", :fields=>:user_name)
    assert !ret.empty?

    ret = Doc.search("n", :operator => "*")
    assert !ret.empty?

    ret = Doc.search("n", :ids=>docs(:doc_2).id, :operator => "*")
    assert !ret.empty?

    ret = Doc.search(["flinstone", 25])
    assert !ret.empty?

    a = {:a=>1, :b=>"x", :c=>[10,20]}
    Doc.store(:hobbies=>a)
    ret = Doc.search a
    assert 1, ret.length
    
  end

  def test_me
    doc = Doc.search 691
    p doc
    assert !doc.empty?

    doc = docs(:doc_3)
    p doc
    doc = Doc.store :b=>"hello"
    p doc
    
  end

  # fields
  def test_should_return_only_current_store_items
    doc = docs(:doc_1)

    active_fields = doc.fields
    assert_equal(1, active_fields.length)
    assert_equal("user_name", active_fields.first.name)
  end

  
end

class View < ActiveRecord::Base
  belongs_to :field

  def after_save
    Doc.all.each do |doc|
      doc.build_it doc.retrieve(doc.id)
    end
  end
  

end

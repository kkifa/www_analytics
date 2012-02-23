
module Fields
  def fields
    @table.keys
  end
end
class OpenStruct
  include Fields
end 

require_relative './data_object'

class Customer < DataObject
  include FirstName, LastName, CreatedAt, UpdatedAt

  def initialize(attributes)
    @editable = [:first_name, :last_name]
    super(attributes)
  end
end

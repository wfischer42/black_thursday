require_relative './data_repository'
require_relative './customer'

class CustomerRepository < DataRepository
  def initialize(data)
    super(data, Customer)
    @searchable = [:first_name, :last_name]
  end

  def customers
    return @data_set.values
  end
end

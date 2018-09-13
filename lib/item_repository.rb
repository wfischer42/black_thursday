require_relative './data_repository'
require_relative './item'

class ItemRepository < DataRepository
  def initialize(data)
    super(data, Item)
    @searchable = [:merchant_id, :description, :unit_price]
  end

  def items
    return @data_set.values
  end
end

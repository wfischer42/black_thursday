require_relative './data_repository'
require_relative './item'

class ItemRepository < DataRepository
  include FindAllByMerchantID, FindAllWithDescription

  def initialize(data)
    super(data, Item)
  end

  def items
    return @data_set.values
  end

  def find_all_by_price(unit_price)
    find_all_by('unit_price', unit_price)
  end

  def find_all_by_price_in_range(range)
    @data_set.values.find_all do |element|
      range.include?(element.unit_price.to_f)
    end
  end
end

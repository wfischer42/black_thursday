require_relative './data_repository'
require_relative './merchant'

class MerchantRepository < DataRepository

  def initialize(data)
    super(data, Merchant)
    @searchable = [:name]
  end

  def merchants
    return @data_set.values
  end
end

require_relative './data_repository'
require_relative './merchant'

class MerchantRepository < DataRepository
  include FindAllByName

  def initialize(data)
    super(data, Merchant)
  end

  def merchants
    return @data_set.values
  end
end

require_relative './data_repository'
require_relative './invoice'

class InvoiceRepository < DataRepository
  include FindAllByMerchantID, FindAllByStatus, FindAllByCustomerID

  def initialize(data)
    super(data, Invoice)
  end

  def invoices
    return @data_set.values
  end
end

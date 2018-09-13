require_relative './data_repository'
require_relative './invoice'

class InvoiceRepository < DataRepository

  def initialize(data)
    super(data, Invoice)
    @searchable = [:merchant_id, :status, :customer_id]
  end

  def invoices
    return @data_set.values
  end
end

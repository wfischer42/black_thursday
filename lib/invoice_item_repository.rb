require_relative './data_repository'
require_relative './invoice_item'

class InvoiceItemRepository < DataRepository
  def initialize(data)
    super(data, InvoiceItem)
    @searchable = [:item_id, :invoice_id]
  end

  def invoice_items
    return @data_set.values
  end
end

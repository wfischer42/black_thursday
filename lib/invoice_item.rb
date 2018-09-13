require_relative './data_object'

class InvoiceItem < DataObject
  include ItemID, InvoiceID, Quantity, UnitPrice, UnitPriceToDollars,
          CreatedAt, UpdatedAt

  def initialize(attributes)
    @editable = [:quantity, :unit_price]
    super(attributes)
  end
end

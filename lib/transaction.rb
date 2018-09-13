require_relative './data_object'

class Transaction < DataObject
  include InvoiceID, CreditCardNumber, CreditCardExpirationDate, Result,
          CreatedAt, UpdatedAt

  def initialize(attributes)
    @editable = [:credit_card_number, :credit_card_expiration_date, :result]
    super(attributes)
  end
end

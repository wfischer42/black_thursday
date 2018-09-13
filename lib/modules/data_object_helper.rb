module CustomerID
  def customer_id
    @attributes[:customer_id]
  end
end

module MerchantID
  def merchant_id
    @attributes[:merchant_id]
  end
end

module InvoiceID
  def invoice_id
    @attributes[:invoice_id]
  end
end

module ItemID
  def item_id
    @attributes[:item_id]
  end
end

module FirstName
  def first_name
    @attributes[:first_name]
  end
end

module LastName
  def last_name
    @attributes[:last_name]
  end
end

module Quantity
  def quantity
    @attributes[:quantity]
  end
end

module Status
  def status
    @attributes[:status]
  end
end

module Description
  def description
    @attributes[:description]
  end
end

module UnitPrice
  def unit_price
    @attributes[:unit_price]
  end
end

module UnitPriceToDollars
  def unit_price_to_dollars
    @attributes[:unit_price].to_f.round(2)
  end
end

module CreditCardNumber
  def credit_card_number
    @attributes[:credit_card_number]
  end
end

module CreditCardExpirationDate
  def credit_card_expiration_date
    @attributes[:credit_card_expiration_date]
  end
end

module Result
  def result
    @attributes[:result]
  end
end

module CreatedAt
  def created_at
    @attributes[:created_at]
  end
end

module UpdatedAt
  def updated_at
    @attributes[:updated_at]
  end
end

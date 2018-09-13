require_relative './data_repository'
require_relative './transaction'

class TransactionRepository < DataRepository
  def initialize(data)
    super(data, Transaction)
    @searchable = [:invoice_id, :credit_card_number, :result]
  end

  def transactions
    return @data_set.values
  end
end

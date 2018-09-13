require_relative './modules/csv_adapter'
require_relative './merchant_repository'
require_relative './item_repository'
require_relative './invoice_repository'
require_relative './sales_analyst'
require_relative './transaction_repository'
require_relative './customer_repository'
require_relative './invoice_item_repository'


class SalesEngine
  extend CSVAdapter

  attr_reader :merchants,
              :items,
              :invoices,
              :analyst,
              :transactions,
              :customers,
              :invoice_items

  def initialize(repositories)
    @merchants = repositories[:merchants]
    @items = repositories[:items]
    @invoices = repositories[:invoices]
    @analyst = SalesAnalyst.new(self)
    @transactions = repositories[:transactions]
    @customers = repositories[:customers]
    @invoice_items = repositories[:invoice_items]
  end

  def self.from_csv(file_hash)
    initializers = {items: ItemRepository,
                    merchants: MerchantRepository,
                    invoices: InvoiceRepository,
                    transactions: TransactionRepository,
                    customers: CustomerRepository,
                    invoice_items: InvoiceItemRepository}
    repositories = {}
    # XXX: Change to inject pattern? Maybe?
    file_hash.each do |dataset, filename|
      data = hash_from_csv(filename)
      repositories[dataset] = initializers[dataset].new(data) if initializers[dataset]
    end

    self.new(repositories)
  end
end

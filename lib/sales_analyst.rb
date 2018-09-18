require_relative './modules/precision_math'
require 'time'

class SalesAnalyst
  include PrecisionMath
  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end

  def average_items_per_merchant
    counts = things_per_merchant(@engine.items)
    average(counts).to_f.round(2)
  end

  def average_items_per_merchant_standard_deviation
    counts = things_per_merchant(@engine.items)
    stdev(counts).to_f.round(2)
  end

  def average_invoices_per_merchant
    counts = things_per_merchant(@engine.invoices)
    average(counts).to_f.round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    counts = things_per_merchant(@engine.invoices)
    stdev(counts).to_f.round(2)
  end

  def things_per_merchant(things)
    counts = @engine.merchants.all.inject([]) do |accumulator, merch|
      accumulator << things.find_all_by_merchant_id(merch.id).length
    end
  end

  def merchants_with_high_item_count
    avg = average_items_per_merchant
    stdev = average_items_per_merchant_standard_deviation
    threshold = avg + stdev
    @engine.merchants.all.find_all do |merchant|
      items = @engine.items.find_all_by_merchant_id(merchant.id)
      items.length > threshold
    end
  end

  def average_item_price_for_merchant(id)
    items = @engine.items.find_all_by_merchant_id(id)
    prices = items.map do |item|
      item.unit_price
    end
    float = average(prices).to_f.round(2)
    BigDecimal.new(float, float.to_s.length)
  end

  def average_average_price_per_merchant
    merchants = @engine.merchants.all
    average_prices = merchants.inject([]) do |averages, merchant|
      averages << average_item_price_for_merchant(merchant.id)
    end
    float = average(average_prices).to_f.round(2)
    BigDecimal.new(float, float.to_s.length)
  end

  def golden_items
    items = @engine.items.all
    item_prices = items.map do |item|
      item.unit_price
    end
    threshold = average(item_prices) + (2 * stdev(item_prices))
    items.find_all do |item|
      item.unit_price > threshold
    end
  end

  def top_merchants_by_invoice_count
    merchants = @engine.merchants.all
    threshold = average_invoices_per_merchant + 2 * average_invoices_per_merchant_standard_deviation
    merchants.inject([]) do |top_merchants, merch|
      invoices = @engine.invoices.find_all_by_merchant_id(merch.id)
      top_merchants << merch if invoices.length > threshold
      top_merchants
    end
  end

  # TODO: DRY this up
  def bottom_merchants_by_invoice_count
    merchants = @engine.merchants.all
    threshold = average_invoices_per_merchant - 2 * average_invoices_per_merchant_standard_deviation
    merchants.inject([]) do |top_merchants, merch|
      invoices = @engine.invoices.find_all_by_merchant_id(merch.id)
      top_merchants << merch if invoices.length < threshold
      top_merchants
    end
  end

  def top_days_by_invoice_count
    counts = invoice_counts_by_weekday
    threshold = average(counts.values) + stdev(counts.values)
    counts.inject([]) do |top_days, day_count|
      top_days << day_count[0] if day_count[1] > threshold
      top_days
    end
  end

  def invoice_counts_by_weekday
    @engine.invoices.all.inject(Hash.new(0)) do |day_counts, invoice|
      day = invoice.created_at.strftime("%A")
      day_counts[day] += 1
      day_counts
    end
  end

  def invoice_counts_by_status
    @engine.invoices.all.inject(Hash.new(0)) do |status_counts, invoice|
      status_counts[invoice.status] += 1
      status_counts
    end
  end

  def invoice_status(status)
    counts = invoice_counts_by_status
    total_count = @engine.invoices.all.length
    ((counts[status].to_f / total_count) * 100).round(2)
  end

  def invoice_paid_in_full?(id)
    transactions = @engine.transactions.find_all_by_invoice_id(id)
    transactions.any? { |trans| trans.result == :success}
  end

  def invoice_total(id)
    return nil unless invoice_paid_in_full?(id)
    invoice_items = @engine.invoice_items.find_all_by_invoice_id(id)
    grand_total = invoice_items.inject(0) do |total, item|
      total += item.total
    end
  end

  def top_buyers(number = 20)
    spending = all_customer_spending
    top_from_value_hash(number, spending)
  end

  def all_customer_spending
    invoices = @engine.invoices.all
    spending = invoices.inject(Hash.new(0)) do |cust_spent, invoice|
      customer = @engine.customers.find_by_id(invoice.customer_id)
      cust_total = invoice_total(invoice.id).to_f
      cust_spent[customer] += cust_total
      cust_spent
    end
  end

  def top_from_value_hash(number, hash)
    top_entries = []
    number.times do
      break if hash.length == 0
      top_entry = hash.max_by do |cust, spent|
        spent
      end[0]
      hash.delete(top_entry)
      top_entries << top_entry
    end
    top_entries
  end

  def top_merchant_for_customer(cust_id)
    invoices = @engine.invoices.find_all_by_customer_id(cust_id)
    purch_per_merch = invoices.inject(Hash.new(0)) do |purchases, inv|

      purchases[inv.merchant_id] += item_quantity_for_invoice(inv.id) #if invoice_paid_in_full?(inv.id)
      purchases
    end
    top_merchant_id = purch_per_merch.max_by do |merch_id, buy_count|
      buy_count
    end[0]
    return @engine.merchants.find_by_id(top_merchant_id)
  end

  def item_quantity_for_invoice(inv_id)
    invoice_items = @engine.invoice_items.find_all_by_invoice_id(inv_id)
    quantity = invoice_items.inject(0) do |quantity, item|
      quantity += item.quantity
    end
  end

  def one_time_buyers
    invoices = @engine.invoices.all
    inv_counts = invoices.inject(Hash.new(0)) do |inv_count, inv|
      customer = @engine.customers.find_by_id(inv.customer_id)
      inv_count[customer] += 1
      inv_count
    end
    singles = inv_counts.select do |cust_id, inv_count|
      inv_count == 1
    end.keys
  end

  def one_time_buyers_top_item
    buyers = one_time_buyers
    invoices = find_all_invoices_for_customers(buyers)
    invoice_items = find_inv_items_from_paid_in_full_invoices(invoices)
    find_most_sold_item_from_inv_items(invoice_items)
  end

  def items_bought_in_year(cust_id, year)
    new_invoices = @engine.invoices.find_all_by_customer_id(cust_id)
    years_invoices = find_invoices_for_year(new_invoices, year)
    inv_items = find_inv_items_from_paid_in_full_invoices(years_invoices)
    find_items_for_inventory_items(inv_items)
  end

  def highest_volume_items(cust_id)
    invoices = @engine.invoices.find_all_by_customer_id(cust_id)
    inv_items = find_inv_items_from_invoices(invoices)
    item_counts = item_counts_from_inv_items_by_quantity(inv_items)
    max_quantity = item_counts.max_by do |item, count|
      count
    end[1]
    items_with_quantity(max_quantity, item_counts)
  end

# TODO: refactor for efficiency
  def customers_with_unpaid_invoices
    unpaid_invoices = find_unpaid_invoices
    unpaid_customers = unpaid_invoices.map do |inv|
      @engine.customers.find_by_id(inv.customer_id)
    end.uniq
  end

# TODO: refactor for efficiency
  def best_invoice_by_revenue
    @engine.invoices.all.max_by do |invoice|
      inv_items = find_inv_items_from_paid_in_full_invoices([invoice])
      find_total_revenue_for_inv_items(inv_items)
    end
  end

  def best_invoice_by_quantity
    @engine.invoices.all.max_by do |invoice|
      inv_items = find_inv_items_from_paid_in_full_invoices([invoice])
      find_total_quantity_for_inv_items(inv_items)
    end
  end

  def find_total_quantity_for_inv_items(inv_items)
    inv_items.inject(0) do |quantity, inv_item|
      quantity += inv_item.quantity.to_f
    end
  end

  def find_total_revenue_for_inv_items(inv_items)
    inv_items.inject(0) do |total, inv_item|
      total += inv_item.total.to_f
    end
  end

  def find_unpaid_invoices
    invoices = @engine.invoices.all
    invoices.find_all do |invoice|
      !invoice_paid_in_full?(invoice.id)
    end
  end

  def items_with_quantity(quantity, item_counts)
    item_counts.select do |item, count|
      quantity == count
    end.keys
  end

  def find_invoices_for_year(invoices, year)
    invoices.find_all do |invoice|
      invoice.created_at.year == year
    end
  end

  def find_items_for_inventory_items(inv_items)
    inv_items.map do |inv_item|
      item_id = inv_item.item_id
      @engine.items.find_by_id(item_id)
    end
  end

  def find_all_invoices_for_customers(customers)
    customers.inject([]) do |invoices, buyer|
      new_invoices = @engine.invoices.find_all_by_customer_id(buyer.id)
      invoices.concat(new_invoices)
    end
  end

  def find_inv_items_from_paid_in_full_invoices(invoices)
    invoices.inject([]) do |inv_items, invoice|
      new_inv_items = @engine.invoice_items.find_all_by_invoice_id(invoice.id)
      inv_items.concat(new_inv_items) if invoice_paid_in_full?(invoice.id)
      inv_items
    end
  end

  def find_inv_items_from_invoices(invoices)
    invoices.inject([]) do |inv_items, invoice|
      new_inv_items = @engine.invoice_items.find_all_by_invoice_id(invoice.id)
      inv_items.concat(new_inv_items)
      inv_items
    end
  end

  def find_most_sold_item_from_inv_items(inv_items)
    items = item_counts_from_inv_items_by_quantity(inv_items)
    items.max_by do |item, count|
      count
    end[0]
  end

  def item_counts_from_inv_items_by_quantity(inv_items)
    items = inv_items.inject(Hash.new(0)) do |count, inv_item|
      item = @engine.items.find_by_id(inv_item.item_id)
      count[item] += inv_item.quantity
      count
    end
  end
end

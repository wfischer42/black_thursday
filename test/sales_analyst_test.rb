require_relative './test_helper'
require_relative '../lib/sales_analyst'
require_relative '../lib/sales_engine'
require 'time'

class SalesAnalystTest < Minitest::Test
  def setup
    @engine = SalesEngine.from_csv(items: './test/data/items.csv',
                                   merchants: './test/data/merchants.csv',
                                   invoices: './test/data/invoices.csv',
                                   transactions: './test/data/transactions.csv',
                                   invoice_items: './test/data/invoice_items.csv',
                                   customers: './test/data/customers.csv')

    @analyst = @engine.analyst
  end

  def test_it_exists
    assert_instance_of(SalesAnalyst, @analyst)
  end

  def test_it_has_an_engine
    assert_instance_of(SalesEngine, @analyst.engine)
  end

  def test_it_can_return_average_items_per_merchant
    actual = @analyst.average_items_per_merchant
    assert_instance_of Float, actual
    assert_equal(0.11, actual)
  end

  def test_it_can_return_average_items_per_merchant_standard_deviation
    merch = stub('Merchant', id: 1)
    merch_array = [merch] * 5
    @engine.merchants.stubs(:all).returns(merch_array)
    @engine.items.stubs(:find_all_by_merchant_id).returns([0] * 5, [0] * 3,
                                                          [0] * 6, [0] * 2,
                                                          [0] * 7)

    actual = @analyst.average_items_per_merchant_standard_deviation
    assert_equal(2.07, actual)
  end

  def test_it_returns_merchants_with_high_item_counts
    merch1 = stub('Merchant', id: 1)
    merch2 = stub('Merchant', id: 2)
    merch3 = stub('Merchant', id: 3)
    merch_array = [merch1, merch2, merch3]

    @engine.merchants.stubs(:all).returns(merch_array)
    @engine.items.stubs(:find_all_by_merchant_id).returns(
      [0] * 2, [0] * 3, [0] * 100,
      [0] * 2, [0] * 3, [0] * 100,
      [0] * 2, [0] * 3, [0] * 100)

    actual = @analyst.merchants_with_high_item_count
    assert_equal([merch3], actual)
  end

  def test_it_returns_average_item_price_for_merchant
    item1 = stub('Item', unit_price: BigDecimal.new(25.00, 4))
    item2 = stub('Item', unit_price: BigDecimal.new(30.00, 4))
    item3 = stub('Item', unit_price: BigDecimal.new(5.00, 4))
    @engine.items.stubs(:find_all_by_merchant_id).with(1).returns([item1, item2, item3])
    assert_equal(20, @analyst.average_item_price_for_merchant(1))
  end

  def test_it_returns_average_average_price_per_merchant
    merch1 = stub('Merchant', id: 1)
    merch2 = stub('Merchant', id: 2)
    item1 = stub('Item', unit_price: BigDecimal.new(26.00, 4))
    item2 = stub('Item', unit_price: BigDecimal.new(10.00, 4))
    item3 = stub('Item', unit_price: BigDecimal.new(1.00, 4))
    item4 = stub('Item', unit_price: BigDecimal.new(2.00, 4))
    item5 = stub('Item', unit_price: BigDecimal.new(3.00, 4))

    @engine.merchants.stubs(:all).returns([merch1, merch2])
    @engine.items.stubs(:find_all_by_merchant_id).returns(
                        [item1, item2],[item3, item4, item5])

    assert_equal(10, @analyst.average_average_price_per_merchant)
  end

  def test_it_returns_golden_items
    unit_prices = ['1.0', '1.1', '200', '1.3', '1.4', '1.2']
    item_stubs = unit_prices.map do |price|
      stub('Item', unit_price: BigDecimal.new(price))
    end
    @engine.items.stubs(:all).returns(item_stubs)

    assert_equal([item_stubs[2]], @analyst.golden_items)
  end

  def test_it_can_return_average_invoices_per_merchant
    merch = stub('Merchant', id: 1)
    merch_array = [merch] * 5
    @engine.merchants.stubs(:all).returns(merch_array)
    @engine.invoices.stubs(:find_all_by_merchant_id).returns([0] * 5, [0] * 3,
                                                             [0] * 6, [0] * 2,
                                                             [0] * 7)

    actual = @analyst.average_invoices_per_merchant
    assert_instance_of(Float, actual)
    assert_equal(4.6, actual)
  end

  def test_it_can_return_average_invoices_per_merchant_standard_deviation
    merch = stub('Merchant', id: 1)
    merch_array = [merch] * 5
    @engine.merchants.stubs(:all).returns(merch_array)
    @engine.invoices.stubs(:find_all_by_merchant_id).returns([0] * 5, [0] * 3,
                                                             [0] * 6, [0] * 2,
                                                             [0] * 7)

    actual = @analyst.average_invoices_per_merchant_standard_deviation
    assert_equal(2.07, actual)
  end

  def test_it_can_return_top_merchants_by_invoice_count
    merch_ids = [1, 2, 3, 4, 5, 6]
    merchants = merch_ids.map do |id|
      stub('Merchant', id: id)
    end

    @engine.merchants.stubs(:all).returns(merchants)
    @engine.invoices.stubs(:find_all_by_merchant_id).returns(
      [0] * 5, [0] * 3, [0] * 6, [0] * 2, [0] * 7, [0] * 1000,
      [0] * 5, [0] * 3, [0] * 6, [0] * 2, [0] * 7, [0] * 1000,
      [0] * 5, [0] * 3, [0] * 6, [0] * 2, [0] * 7, [0] * 1000)

    actual = @analyst.top_merchants_by_invoice_count
    assert_equal([merchants[5]], actual)
  end

  def test_it_can_return_bottom_merchants_by_invoice_count
    merch_ids = [1, 2, 3, 4, 5, 6]
    merchants = merch_ids.map do |id|
      stub('Merchant', id: id)
    end

    @engine.merchants.stubs(:all).returns(merchants)
    @engine.invoices.stubs(:find_all_by_merchant_id).returns(
      [0] * 1000, [0] * 1000, [0] * 1, [0] * 1000, [0] * 1000, [0] * 1000,
      [0] * 1000, [0] * 1000, [0] * 1, [0] * 1000, [0] * 1000, [0] * 1000,
      [0] * 1000, [0] * 1000, [0] * 1, [0] * 1000, [0] * 1000, [0] * 1000)

    actual = @analyst.bottom_merchants_by_invoice_count
    assert_equal([merchants[2]], actual)
  end

  def test_it_can_show_invoice_counts_by_weekday
    we = Time.parse('2018-09-12 17:45:35 -0600')
    th = Time.parse('2018-09-13 17:45:35 -0600')
    fr = Time.parse('2018-09-14 17:45:35 -0600')
    sa = Time.parse('2018-09-15 17:45:35 -0600')
    su = Time.parse('2018-09-16 17:45:35 -0600')
    mo = Time.parse('2018-09-17 17:45:35 -0600')
    tu = Time.parse('2018-09-18 17:45:35 -0600')

    weekdays = [we, th, fr, sa, su, mo, [tu] * 1000].flatten
    invoices = weekdays.map do |day|
      stub('Invoice', created_at: day)
    end
    @engine.invoices.stubs(:all).returns(invoices)
    expected = {  "Wednesday" => 1, "Thursday" => 1, "Friday" => 1,
                  "Saturday" => 1, "Sunday" => 1, "Monday" => 1,
                  "Tuesday" => 1000 }
    actual = @analyst.invoice_counts_by_weekday
    assert_equal(expected, actual)
  end

  def test_it_can_show_top_days_by_invoice_count
    we = Time.parse('2018-09-12 17:45:35 -0600')
    th = Time.parse('2018-09-13 17:45:35 -0600')
    fr = Time.parse('2018-09-14 17:45:35 -0600')
    sa = Time.parse('2018-09-15 17:45:35 -0600')
    su = Time.parse('2018-09-16 17:45:35 -0600')
    mo = Time.parse('2018-09-17 17:45:35 -0600')
    tu = Time.parse('2018-09-18 17:45:35 -0600')

    weekdays = [we, th, fr, sa, su, mo, [tu] * 1000].flatten
    invoices = weekdays.map do |day|
      stub('Invoice', created_at: day)
    end
    @engine.invoices.stubs(:all).returns(invoices)
    expected = ["Tuesday"]
    actual = @analyst.top_days_by_invoice_count
    assert_equal(expected, actual)
  end

  def test_it_can_return_percentages_by_invoice_status
    statuses = [ [:pending] * 30, [:shipped] * 45, [:returned] * 25 ].flatten
    invoices = statuses.map do |status|
      stub('Invoice', status: status)
    end
    @engine.invoices.stubs(:all).returns(invoices)
    assert_equal(30.0, @analyst.invoice_status(:pending))
    assert_equal(45.0, @analyst.invoice_status(:shipped))
    assert_equal(25.0, @analyst.invoice_status(:returned))
  end

  def test_it_can_tell_if_paid_in_full
    trans1 = stub("transaction", id: 432, invoice_id: 123, result: :success)
    trans2 = stub("transaction", id: 789, invoice_id: 864, result: :failure)
    @engine.transactions.stubs(:all).returns([trans1, trans2])
    assert(@analyst.invoice_paid_in_full?(123))
    refute(@analyst.invoice_paid_in_full?(864))
  end

  def test_it_can_give_invoice_total
    expected = 5289.13
    actual = @analyst.invoice_total(2)
    assert_equal(expected, actual)
  end

  def test_it_returns_nil_for_invoice_total_if_not_paid_in_full
    actual = @analyst.invoice_total(3)
    assert_nil(actual)
  end

  def test_it_can_list_top_buyers
    expected_first = 1
    expected_last = 5
    actual = @analyst.top_buyers(5)
    assert_equal(expected_first, actual[0].id)
    assert_equal(expected_last, actual[-1].id)
  end

  def test_it_lists_top_20_buyers_by_default
    expected = 20
    actual = @analyst.top_buyers
    assert_equal(expected, actual.length)
  end

  def test_it_can_give_top_merchant_for_customer
    expected = 12335938
    actual = @analyst.top_merchant_for_customer(1)
    assert_equal(expected, actual.id)
    assert_instance_of(Merchant, actual)
  end

  def test_it_can_find_one_time_buyers
    expected = 26
    actual = @analyst.one_time_buyers
    assert_equal(expected, actual[0].id)
  end

  def test_it_can_find_top_item_for_one_time_buyers
    expected = 263512345
    actual = @analyst.one_time_buyers_top_item
    assert_equal(expected, actual.id)
  end

  def test_it_can_find_items_bought_in_year
    expected = 263519844
    actual = @analyst.items_bought_in_year(1, 2009)
    assert_equal(expected, actual[0].id)
  end

  def test_it_can_find_highest_volume_items_for_customer
    expected = 263539664
    actual = @analyst.highest_volume_items(1)
    assert_equal(expected, actual[0].id)
  end

  def test_it_can_find_customers_with_unpaid_invoices
    expected_first = 1
    expected_last = 25
    actual = @analyst.customers_with_unpaid_invoices
    assert_equal(expected_first, actual[0].id)
    assert_equal(expected_last, actual[-1].id)
  end

  def test_it_can_find_best_invoice_by_revenue
    expected = 1
    actual = @analyst.best_invoice_by_revenue
    assert_equal(expected, actual.id)
  end

  def test_it_can_find_best_invoice_by_quantity
    expected = 1
    actual = @analyst.best_invoice_by_quantity
    assert_equal(expected, actual.id)
  end
end

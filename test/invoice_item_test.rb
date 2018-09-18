require_relative 'test_helper'
require_relative '../lib/invoice_item'

class InvoiceItemTest < Minitest::Test
  def setup
    @time1 = '1993-10-28 11:56:40 UTC'
    @time2 = '1993-09-29 12:45:30 UTC'
    @attributes = { id:           123,
                    item_id:      369,
                    invoice_id:   456,
                    quantity:     12,
                    unit_price:   BigDecimal.new(12.00, 4),
                    created_at:   Time.parse(@time1),
                    updated_at:   Time.parse(@time2) }
    @invoice_item = InvoiceItem.new(@attributes)
  end

  def test_it_exists
    assert_instance_of(InvoiceItem, @invoice_item)
  end

  def test_it_can_calculate_total
    assert_equal(144, @invoice_item.total)
  end

  def test_it_can_show_attributes
    assert_equal(123, @invoice_item.id)
    assert_equal(369, @invoice_item.item_id)
    assert_equal(456, @invoice_item.invoice_id)
    assert_equal(12, @invoice_item.quantity)
    assert_equal(BigDecimal.new(12.00, 4), @invoice_item.unit_price)
    assert_equal(Time.parse(@time1), @invoice_item.created_at)
    assert_equal(Time.parse(@time2), @invoice_item.updated_at)
  end
end

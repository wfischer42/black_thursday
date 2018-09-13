require_relative 'test_helper'
require_relative '../lib/invoice_item_repository'

class InvoiceItemRepositoryTest < Minitest::Test
  def test_it_exists
    inv = stub('Inventory')
    InvoiceItem.stubs(:from_raw_hash).returns(inv)
    repo = InvoiceItemRepository.new([{id: 0}])
    assert_instance_of InvoiceItemRepository, repo
  end

  def test_it_can_find_all_invoice_items_by_item_id
    invoice_item1 = stub('Invoice Item', id: 123, item_id: 1234)
    invoice_item2 = stub('Invoice Item', id: 456, item_id: 4567)
    invoice_item3 = stub('Invoice Item', id: 321, item_id: 1234)
    InvoiceItem.stubs(:from_raw_hash).returns(invoice_item1, invoice_item2, invoice_item3)
    datas = [{id: 123}, {id: 456}, {id: 321}]
    repo = InvoiceItemRepository.new(datas)
    assert_equal([invoice_item1, invoice_item3], repo.find_all_by_item_id(1234))
  end

  def test_it_can_find_all_invoice_items_by_invoice_id
    invoice_item1 = stub('Invoice Item', id: 123, invoice_id: 1234)
    invoice_item2 = stub('Invoice Item', id: 456, invoice_id: 4567)
    invoice_item3 = stub('Invoice Item', id: 321, invoice_id: 1234)
    InvoiceItem.stubs(:from_raw_hash).returns(invoice_item1, invoice_item2, invoice_item3)
    datas = [{id: 123}, {id: 456}, {id: 321}]
    repo = InvoiceItemRepository.new(datas)
    assert_equal([invoice_item1, invoice_item3], repo.find_all_by_invoice_id(1234))
  end

end

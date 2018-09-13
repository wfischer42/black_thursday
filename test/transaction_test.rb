require_relative 'test_helper'
require_relative '../lib/transaction'

class TransactionTest < Minitest::Test
  def setup
    @time1 = '1993-10-28 11:56:40 UTC'
    @time2 = '1993-09-29 12:45:30 UTC'
    @attributes = { id:                           123,
                    invoice_id:                   369,
                    credit_card_number:           '4567123444356654',
                    credit_card_expiration_date:  '0220',
                    result:                       'success',
                    created_at:                   Time.parse(@time1),
                    updated_at:                   Time.parse(@time2) }
    @transaction = Transaction.new(@attributes)
  end

  def test_it_exists
    assert_instance_of(Transaction, @transaction)
  end

  def test_it_can_show_attributes
    assert_equal(123, @transaction.id)
    assert_equal(369, @transaction.invoice_id)
    assert_equal('4567123444356654', @transaction.credit_card_number)
    assert_equal('0220', @transaction.credit_card_expiration_date)
    assert_equal('success', @transaction.result)
    assert_equal(Time.parse(@time1), @transaction.created_at)
    assert_equal(Time.parse(@time2), @transaction.updated_at)
  end
end

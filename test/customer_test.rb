require_relative 'test_helper'
require_relative '../lib/customer'

class CustomerTest < Minitest::Test
  def setup
    @time1 = '1993-10-28 11:56:40 UTC'
    @time2 = '1993-09-29 12:45:30 UTC'
    @attributes = { id:           123,
                    first_name:   'John',
                    last_name:    'Wick',
                    created_at:   Time.parse(@time1),
                    updated_at:   Time.parse(@time2) }
    @customer = Customer.new(@attributes)
  end

  def test_it_exists
    assert_instance_of(Customer, @customer)
  end

  def test_it_can_show_attributes
    assert_equal(123, @customer.id)
    assert_equal('John', @customer.first_name)
    assert_equal('Wick', @customer.last_name)
    assert_equal(Time.parse(@time1), @customer.created_at)
    assert_equal(Time.parse(@time2), @customer.updated_at)
  end
end

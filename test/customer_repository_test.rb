require_relative 'test_helper'
require_relative '../lib/customer_repository'

class CustomerRepositoryTest < Minitest::Test
  def test_it_exists
    cust = stub('Customer')
    Customer.stubs(:from_raw_hash).returns(cust)
    repo = CustomerRepository.new([{id: 0}])
    assert_instance_of CustomerRepository, repo
  end

  def test_it_has_customers
    cust1 = stub('Customer', id: 0)
    cust2 = stub('Customer', id: 1)
    Customer.stubs(:from_raw_hash).returns(cust1, cust2)
    repo = CustomerRepository.new([{id: 0}, {id: 1}])
    assert_equal([cust1, cust2], repo.customers)
  end

end

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

  def test_it_can_find_customers_by_first_or_last_name
    cust1 = stub('Customer', id: 0, first_name: 'John', last_name: 'Jones')
    cust2 = stub('Customer', id: 1, first_name: 'Davey', last_name: 'Public')
    cust3 = stub('Customer', id: 2, first_name: 'Davey', last_name: 'Jones')
    Customer.stubs(:from_raw_hash).returns(cust1, cust2, cust3)
    repo = CustomerRepository.new([{id: 0}, {id: 1}, {id: 2}])
    assert_equal([cust2, cust3], repo.find_all_by_first_name('Davey'))
    assert_equal([cust1, cust3], repo.find_all_by_last_name('Jones'))
  end

  def test_it_cant_find_by_unsearchable_attribute
    cust1 = stub('Customer', id: 0, first_name: 'John', last_name: 'Jones')
    Customer.stubs(:from_raw_hash).returns(cust1)
    repo = CustomerRepository.new([{id: 0}])
    assert_raises NoMethodError do
      repo.find_all_by_result(:success)
    end
  end

end

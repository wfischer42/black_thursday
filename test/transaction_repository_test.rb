require_relative 'test_helper'
require_relative '../lib/transaction_repository'

class TransactionRepositoryTest < Minitest::Test
  def test_it_exists
    trans = stub('Transaction')
    Transaction.stubs(:from_raw_hash).returns(trans)
    repo = TransactionRepository.new([{id: 0}])
    assert_instance_of TransactionRepository, repo
  end

  def test_it_can_find_all_transactions_by_credit_card_number
    transaction1 = stub('Transaction', id: 123, credit_card_number: '1234')
    transaction2 = stub('Transaction', id: 456, credit_card_number: '4567')
    transaction3 = stub('Transaction', id: 321, credit_card_number: '1234')
    Transaction.stubs(:from_raw_hash).returns(transaction1, transaction2, transaction3)
    datas = [{id: 123}, {id: 456}, {id: 321}]
    repo = TransactionRepository.new(datas)
    assert_equal([transaction1, transaction3], repo.find_all_by_credit_card_number('1234'))
  end

  def test_it_can_find_all_transactions_by_result
    transaction1 = stub('Transaction', id: 123, result: 'failure')
    transaction2 = stub('Transaction', id: 456, result: 'success')
    transaction3 = stub('Transaction', id: 321, result: 'failure')
    Transaction.stubs(:from_raw_hash).returns(transaction1, transaction2, transaction3)
    datas = [{id: 123}, {id: 456}, {id: 321}]
    repo = TransactionRepository.new(datas)
    assert_equal([transaction1, transaction3], repo.find_all_by_result('failure'))
  end
end

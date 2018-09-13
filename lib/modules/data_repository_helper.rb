module FindAllBy
  private
  def find_all_by(type, value, substring: false)
    @data_set.values.find_all do |element|
      if substring
        element.send(type).downcase.include?(value.downcase)
      else
        element.send(type) == value
      end
    end
  end
end

module FindAllByName
  include FindAllBy
  def find_all_by_name(name)
    find_all_by('name', name, substring: true)
  end
end

module FindAllWithDescription
  include FindAllBy
  def find_all_with_description(description)
    find_all_by('description', description, substring: true)
  end
end

module FindAllByMerchantID
  include FindAllBy
  def find_all_by_merchant_id(id)
    find_all_by('merchant_id', id)
  end
end

module FindAllByStatus
  include FindAllBy
  def find_all_by_status(status)
    find_all_by('status', status)
  end
end

module FindAllByCustomerID
  include FindAllBy
  def find_all_by_customer_id(id)
    find_all_by('customer_id', id)
  end
end

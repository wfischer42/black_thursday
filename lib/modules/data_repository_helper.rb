module FindAllBy
  def find_all_by(type, value, substring: false, range: false)
    unless @searchable.include?(type)
      raise NoMethodError, "undefined method `#{type}' for #{self.inspect}"
    end
    @data_set.values.find_all do |element|
      if substring
        element.send(type).downcase.include?(value.downcase)
      elsif range
        value.include?(element.send(type).to_f)
      else
        element.send(type) == value
      end
    end
  end

  def find_all_by_name(name)
    find_all_by(:name, name, substring: true)
  end

  def find_all_with_description(description)
    find_all_by(:description, description, substring: true)
  end

  def find_all_by_merchant_id(id)
    find_all_by(:merchant_id, id)
  end

  def find_all_by_price(unit_price)
    find_all_by(:unit_price, unit_price)
  end

  def find_all_by_price_in_range(range)
    find_all_by(:unit_price, range, range: true)
  end

  def find_all_by_status(status)
    find_all_by(:status, status)
  end

  def find_all_by_customer_id(id)
    find_all_by(:customer_id, id)
  end
end

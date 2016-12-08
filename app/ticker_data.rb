class TickerData
  attr_reader :currency_pair, :id, :last, :lowest_ask, :highest_bid, :percent_change, :base_volume, :quote_volume, :is_frozen, :high24hr, :low24hr

  def initialize currency_pair, hash
    @currency_pair = currency_pair
    hash.each { |k, v| instance_variable_set("@#{k.underscore.to_sym}", BigDecimal.new(v)) }
  end

  def to_h
    instance_variables.map { |x| [x[1..-1].to_sym, instance_variable_get(x)] }.to_h
  end
end

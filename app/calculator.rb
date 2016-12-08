class Calculator
  THRESHOLD_PERIOD = 4320
  LONG_PERIOD = 1200
  SHORT_PERIOD = 300

  def initialize currency_pair
    @currency_pair = currency_pair
  end

  def to_h
    %i(price threshold long short_sma short_ema).map { |x| [x, send(x)] }.to_h
  end

  private

  def file
    File.join(Config.root, 'temp', @currency_pair)
  end

  def last_x_prices period
    `tail --lines=#{period} #{file} | paste -sd+`.split('+').map { |x| BigDecimal.new x }
  end

  def price
    BigDecimal.new `tail --lines=1 #{file}`
  end

  def threshold
    BigDecimal.new(`tail --lines=#{THRESHOLD_PERIOD} #{file} | paste -sd+ | bc`) / THRESHOLD_PERIOD
  end
  
  def long
    BigDecimal.new(`tail --lines=#{LONG_PERIOD} #{file} | paste -sd+ | bc`) / LONG_PERIOD
  end

  def short_sma
    BigDecimal.new(`tail --lines=#{SHORT_PERIOD} #{file} | paste -sd+ | bc`) / SHORT_PERIOD
  end

  def short_ema
    last_x_prices(SHORT_PERIOD).ema
  end
end

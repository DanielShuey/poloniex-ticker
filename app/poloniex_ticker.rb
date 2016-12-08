class PoloniexTicker
  REPEAT_PERIOD = 2

  class << self
    def run
      Rufus::Scheduler.new.tap { |s| s.every("#{PoloniexTicker::REPEAT_PERIOD}m") { perform } }.join
    end

    def perform
      build_ticker_data
      update_prices
      update_ticker
      update_charts
    end

    def chart_data currency_pair
      file = File.join(Config.root, 'temp', "#{currency_pair}_chart.csv")
      
      @price = @threshold = @long = @short_sma = @short_ema = []

      CSV.foreach(file) do |row|
        @price << row[11]
        @threshold << row[12]
        @long << row[13]
        @short_sma << row[14]
        @short_ema << row[15]
      end

      {
        price: @price,
        threshold: @threshold,
        long: @long,
        short_sma: @short_sma,
        short_ema: @short_ema
      }
    end

    private

    def build_ticker_data
      @ticker_data = JSON.parse(Poloniex.ticker.body).select { |k, v| k.start_with? 'BTC' }.map { |k, v| TickerData.new(k, v) }
    end

    def update_prices
      @ticker_data.each do |x|
        price = (x.lowest_ask + x.highest_bid) / 2
        file = File.join(Config.root, 'temp', x.currency_pair)
        `echo #{price} >> #{file}`
        `tail --lines=11000 #{file} | sponge #{file}`
      end
    end

    def update_ticker
      @compiled_ticker = @ticker_data.map { |x| x.to_h.merge(Calculator.new(x.currency_pair).to_h) }
      File.open(File.join(ENV['HOME'], 'poloniex_ticker.json'), 'w') { |f| f.write(JSON.generate(@compiled_ticker)) }
    end

    def update_charts
      @compiled_ticker.each do |x| 
        file = File.join(Config.root, 'temp', "#{x[:currency_pair]}_chart.csv")
        `echo #{x.values.join(',')} >> #{file}`
        `tail --lines=#{Calculator::THRESHOLD_PERIOD + 1} #{file} | sponge #{file}`
      end
    end
  end
end

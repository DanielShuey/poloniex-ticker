class Poloniex
  class << self
    class API
      include HTTParty
      # debug_output $stdout # Debugging to Stdout
      base_uri 'https://poloniex.com/'
    end

    def ticker
      get 'returnTicker'
    end

    private

    def get command, **params
      API.get "/public", { query: { command: command }.merge(params) }
    end

    def current_time
      Time.now.getutc.to_i
    end
  end
end

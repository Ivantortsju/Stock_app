class Stock
  AVAILABLE_STOCKS = ['AAPL', 'GOOG', 'MSFT', 'AMZN', 'TSLA', 'NVDA']
  attr_accessor :ticker, :name, :last_price, :quantity

  def initialize(ticker:, name:, last_price:)
    @ticker = ticker
    @name = name
    @last_price = last_price
  end

  def self.new_lookup(ticker_symbol)
    ticker = ticker_symbol.upcase
    # Try cache first
    cached = StockQuote.recent_for(ticker)
    if cached
      return new(ticker: cached.ticker, name: cached.name || ticker, last_price: cached.last_price.to_f)
    end

    require 'uri'
    require 'net/http'
    require 'json'
    url = URI("https://alpha-vantage.p.rapidapi.com/query?function=TIME_SERIES_DAILY&symbol=#{ticker}&outputsize=compact&datatype=json")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = Rails.application.credentials.rapidapi[:x_rapidapi_key]
    request["x-rapidapi-host"] = 'alpha-vantage.p.rapidapi.com'
    begin
      response = http.request(request)
      response_body = response.read_body
      Rails.logger.info "---"
      Rails.logger.info "API Response for #{ticker}:"
      Rails.logger.info response_body
      Rails.logger.info "---"
      result = JSON.parse(response_body)
      if result.nil? || result['Error Message'] || result['Information'] || result['Time Series (Daily)'].nil?
        Rails.logger.error "API call failed or returned invalid data for #{ticker}. Response: #{response_body}"
        return nil
      end
      last_refreshed_data = result['Time Series (Daily)'].first
      last_price = last_refreshed_data.last['4. close']
      stock = new(ticker: ticker, name: ticker, last_price: last_price.to_f)
      # Save to cache
      StockQuote.create!(ticker: ticker, name: ticker, last_price: last_price, fetched_at: Time.current)
      stock
    rescue => e
      Rails.logger.error "Error fetching stock data for #{ticker}: #{e.message}"
      return nil
    end
  end
end

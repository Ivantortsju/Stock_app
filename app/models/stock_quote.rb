class StockQuote < ApplicationRecord
  validates :ticker, presence: true
  validates :last_price, presence: true
  validates :fetched_at, presence: true

  def self.recent_for(ticker, max_age_minutes = 5)
    where(ticker: ticker.upcase)
      .where('fetched_at >= ?', Time.current - max_age_minutes.minutes)
      .order(fetched_at: :desc)
      .first
  end
end

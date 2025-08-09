class Transaction < ApplicationRecord
  belongs_to :user

  validates :ticker, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true }
  validate :quantity_sign_matches_type
  validates :price_per_share, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_type, presence: true, inclusion: { in: %w(buy sell) }
  private

  def quantity_sign_matches_type
    if transaction_type == 'buy' && (!quantity.is_a?(Integer) || quantity <= 0)
      errors.add(:quantity, 'must be greater than 0 for buy transactions')
    elsif transaction_type == 'sell' && (!quantity.is_a?(Integer) || quantity >= 0)
      errors.add(:quantity, 'must be less than 0 for sell transactions')
    end
  end
end

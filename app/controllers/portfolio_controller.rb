class PortfolioController < ApplicationController
  before_action :authenticate_user!

  def index
    @portfolio_stocks = current_user.transactions.group(:ticker).sum(:quantity)
    @portfolio_stocks.reject! { |_, quantity| quantity.zero? }
    @stocks = @portfolio_stocks.map do |symbol, shares|
      stock = Stock.new_lookup(symbol)
      if stock
        stock.quantity = shares
        stock
      end
    end.compact
    if @portfolio_stocks.any? && @stocks.empty?
      flash.now[:alert] = 'Stock price API is currently unavailable. Portfolio prices may not be up to date.'
    end
  end

  def sell
    @stock = Stock.new_lookup(params[:ticker])
    return redirect_to my_portfolio_path, alert: "Could not retrieve stock information for #{params[:ticker]}. Please try again later." unless @stock
    @owned_shares = current_user.transactions.where(ticker: params[:ticker]).sum(:quantity)
  end

  def confirm_sell
    ticker = params[:ticker]
    quantity_to_sell = params[:quantity].to_i
    stock = Stock.new_lookup(ticker)
    fallback_price = current_user.transactions.where(ticker: ticker).order(created_at: :desc).pluck(:price_per_share).first
    unless stock
      price = fallback_price || 100.00
      stock = OpenStruct.new(ticker: ticker, last_price: price, name: ticker)
      flash[:alert] = fallback_price ? "Using fallback price due to API limit." : "Using default price ($#{price}) due to missing API and fallback price."
    end
    owned_quantity = current_user.transactions.where(ticker: ticker).sum(:quantity)
    if quantity_to_sell <= 0
      return redirect_to my_portfolio_path, alert: 'Please enter a valid quantity to sell.'
    end
    if owned_quantity < quantity_to_sell
      redirect_to my_portfolio_path, alert: "You do not own enough shares to sell."
      return
    end
    ActiveRecord::Base.transaction do
      transaction = current_user.transactions.build(
        ticker: stock.ticker,
        quantity: -quantity_to_sell,
        price_per_share: stock.last_price,
        transaction_type: 'sell'
      )
      if transaction.valid?
        transaction.save!
        total_earned = quantity_to_sell * stock.last_price
        current_user.update!(funds: current_user.funds + total_earned)
        redirect_to my_portfolio_path, notice: "Successfully sold #{quantity_to_sell} shares of #{stock.name}."
      else
        redirect_to my_portfolio_path, alert: "Sale failed: #{transaction.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    redirect_to my_portfolio_path, alert: 'An error occurred while processing the sale. Please try again.'
  end
end

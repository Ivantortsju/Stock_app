class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_approved_trader

  def search
    if params[:stock].present?
      @stock = Stock.new_lookup(params[:stock])
      if @stock
        render 'stocks/search'
      else
        flash[:alert] = 'Stock price API rate limit exceeded. Please wait a minute and try again.' unless Rails.logger.instance_variable_get(:@logdev)&.dev&.string&.include?("You have exceeded the rate limit")
        redirect_to search_stock_path
      end
    else
      @available_stocks = Stock::AVAILABLE_STOCKS.map { |ticker| Stock.new_lookup(ticker) }.compact
      flash.now[:alert] = 'Stock price API is currently unavailable. Please try again later.' if @available_stocks.empty?
    end
  end

  def buy
    stock = Stock.new_lookup(params[:ticker])
    shares = params[:shares].to_i
    if stock && shares > 0
      total_cost = shares * stock.last_price
      if current_user.funds >= total_cost
        ActiveRecord::Base.transaction do
          current_user.transactions.create!(
            ticker: stock.ticker,
            quantity: shares,
            price_per_share: stock.last_price,
            transaction_type: 'buy'
          )
          current_user.update!(funds: current_user.funds - total_cost)
          current_user.reload
        end
        flash[:notice] = "You have successfully purchased #{shares} shares of #{stock.name}."
      else
        flash[:alert] = "Insufficient funds to complete this purchase. Please deposit more funds or reduce the number of shares."
        redirect_to search_stock_path and return
      end
    else
      flash[:alert] = "There was an error with your purchase. The API is currently unavailable. Please try again later."
    end
    redirect_to search_stock_path
  end

  private

  def check_if_approved_trader
    return if current_user.role == 'admin'
    redirect_to dashboard_index_path, alert: 'You are not authorized to access this page.' unless current_user.role == 'trader' && current_user.approved?
  end
end 

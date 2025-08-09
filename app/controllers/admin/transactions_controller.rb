class Admin::TransactionsController < Admin::BaseController
  def index
    @transactions = ::Transaction.all

    if params[:q].present?
      q = "%#{params[:q].strip.downcase}%"
      @transactions = @transactions.joins(:user).where(
        'LOWER(users.email) LIKE :q OR LOWER(transactions.ticker) LIKE :q OR LOWER(transactions.transaction_type) LIKE :q OR CAST(transactions.created_at AS TEXT) LIKE :q OR CAST(transactions.price_per_share AS TEXT) LIKE :q',
        q: q
      )
    end

    sort_column = %w[email ticker quantity price_per_share transaction_type created_at].include?(params[:sort]) ? params[:sort] : 'created_at'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    order_by = sort_column == 'email' ? "users.email" : sort_column
    @transactions = @transactions.joins(:user).order("#{order_by} #{sort_direction}")
  end
end
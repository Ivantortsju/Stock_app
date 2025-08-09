class Admin::PendingTradersController < Admin::BaseController
  def index
    @pending_traders = User.where(role: 'trader', approved: false)
    if params[:q].present?
      pattern = "%#{params[:q].strip.downcase}%"
      @pending_traders = @pending_traders.where(
        'lower(email) LIKE ? OR lower(name) LIKE ? OR lower(surname) LIKE ?',
        pattern, pattern, pattern
      )
    end
    sort_column = %w[name surname email].include?(params[:sort]) ? params[:sort] : 'name'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @pending_traders = @pending_traders.order("#{sort_column} #{sort_direction}")
  end

  def update
    update_trader_status(true, 'Trader approved.', 'Failed to approve trader.')
  end

  def destroy
    if User.find(params[:id]).destroy
      redirect_to admin_pending_traders_path, notice: 'Trader rejected and deleted.'
    else
      redirect_to admin_pending_traders_path, alert: 'Failed to reject trader.'
    end
  end

  private

  def update_trader_status(status, success_msg, failure_msg)
    trader = User.find(params[:id])
    if trader.update(approved: status)
      UserMailer.account_approved_email(trader).deliver_now if status
      redirect_to admin_pending_traders_path, notice: success_msg
    else
      redirect_to admin_pending_traders_path, alert: failure_msg
    end
  end
end
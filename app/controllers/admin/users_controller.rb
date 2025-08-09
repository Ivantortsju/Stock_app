class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :reject]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to admin_users_path, alert: 'User not found.'
  end

  def index
    @users = User.where(role: 'trader', approved: true)
    if params[:q].present?
      pattern = "%#{params[:q].strip.downcase}%"
      @users = @users.where(
        'lower(name) LIKE ? OR lower(surname) LIKE ? OR lower(email) LIKE ?',
        pattern, pattern, pattern
      )
    end
    sort_column = %w[name surname email].include?(params[:sort]) ? params[:sort] : 'name'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @users = @users.order("#{sort_column} #{sort_direction}")
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: 'trader', approved: true))
    if @user.save
      redirect_to admin_users_path, notice: 'Trader was successfully created and approved.'
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    @user.skip_reconfirmation! if @user.respond_to?(:skip_reconfirmation!)
    if @user.save
      redirect_to admin_users_path, notice: 'Trader was successfully updated.'
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    if User.count == 1
      redirect_to admin_users_path, alert: 'Cannot delete the last user.'
    elsif @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete yourself.'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end
  end

  def no_users_yet
    render 'admin/no_users_yet'
  end

  def reject
    if @user.role == 'trader'
      @user.update(approved: false)
      redirect_to admin_users_path, notice: 'Trader moved back to pending approval.'
    else
      redirect_to admin_users_path, alert: 'Only traders can be rejected.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :surname, :email, :password, :password_confirmation)
  end
end
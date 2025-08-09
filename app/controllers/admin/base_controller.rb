class Admin::BaseController < ApplicationController
  before_action :authorize_admin!

  rescue_from ActionController::RoutingError, with: :render_not_found

  private

  def authorize_admin!
    redirect_to root_path, alert: 'You are not authorized to perform this action.' unless current_user.role == 'admin'
  end

  def render_not_found
    render 'errors/not_found', status: :not_found
  end
end

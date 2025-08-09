class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource  # ← Add this line

  rescue_from ActionController::RoutingError, with: :render_not_found

  def render_not_found
    render 'errors/not_found', status: :not_found
  end

  def after_sign_in_path_for(resource)
    dashboard_index_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :surname])
  end

  private

  # This method tells Rails which layout to use based on the controller
  def layout_by_resource
    if devise_controller?
      "devise"  # Use layouts/devise.html.erb for Devise views
    else
      "application"
    end
  end
end

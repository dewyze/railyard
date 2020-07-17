class ApplicationController < ActionController::Base
  include Pundit

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  def after_sign_in_path_for(resource)
    location = stored_location_for(resource)

    return location if location
    return dashboard_path if resource.is_a?(User)

    root_path
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    message = e.respond_to?(:reason) ? I18n.t("pundit.errors.#{e.reason}") : e.message
    flash[:error] = t(message, scope: "pundit", default: :default)
    redirect_path = current_user ? dashboard_path : root_path
    redirect_to(request.referrer || redirect_path)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end

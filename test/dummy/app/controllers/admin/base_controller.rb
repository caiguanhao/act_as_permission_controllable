class Admin::BaseController < ApplicationController
  layout 'admin'

  grant_permission

  before_action do
    I18n.locale = (session[:locale] || I18n.default_locale).to_sym
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json {
        render json: { message: exception.message }, status: 403
      }
      format.html {
        render 'act_as_permission_controllable/forbidden', layout: 'admin', status: 403, locals: { exception: exception }
      }
    end
  end

  private

    def current_admin
      @current_admin ||= Admin.first
    end

    def current_ability
      @current_ability ||= Ability.new(current_admin)
    end

    helper_method :current_admin
end

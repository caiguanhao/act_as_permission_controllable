class Admin::LanguageController < Admin::BaseController
  skip_grant_permission

  def toggle_language
    session[:locale] = I18n.locale == :en ? :zh_CN : :en
    redirect_back fallback_location: admin_root_url
  end
end

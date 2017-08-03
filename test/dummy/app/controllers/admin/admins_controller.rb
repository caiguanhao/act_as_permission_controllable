class Admin::AdminsController < Admin::BaseController
  grant_permission index: :welcome

  before_action :set_admin, only: [ :permissions ]

  def index
  end

  def welcome
  end

  def permissions
    if request.post?
      @admin.assign_permissions(params.fetch(:actions, []))
      if @admin.save
        flash[:notice] = 'OK!'
      else
        flash[:error] = 'ERROR!'
      end
      redirect_to params[:referer].presence || permissions_admin_admin_path(@admin)
      return
    end

    render 'act_as_permission_controllable/permissions'
  end

  private

    def set_admin
      @admin = Admin.find(params[:id])
    end
end

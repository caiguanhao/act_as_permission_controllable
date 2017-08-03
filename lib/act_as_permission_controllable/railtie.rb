module ActAsImportable
  class Railtie < ::Rails::Railtie
    initializer "act_as_permission_controllable.active_record" do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send :include, ActAsPermissionControllable::Act::Model
      end

      ActiveSupport.on_load :action_controller do
        ActionController::Base.send :include, ActAsPermissionControllable::Act::Controller
        ActionController::Base.append_view_path File.expand_path('../../../app/views', __FILE__)
      end

      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, ActAsPermissionControllable::Helper
      end
    end
  end
end

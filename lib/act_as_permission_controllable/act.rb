require 'act_as_permission_controllable/model'

module ActAsPermissionControllable
  module Act
    module Model
      extend ActiveSupport::Concern

      module ClassMethods
        def act_as_permission_controllable
          include ActAsPermissionControllable::Model
        end
      end
    end

    module Controller
      extend ActiveSupport::Concern

      module ClassMethods
        def grant_permission(options = {})
          authorize_resource class: false
          @__permission__ = options.slice(:priority, :index)
        end
      end
    end
  end
end

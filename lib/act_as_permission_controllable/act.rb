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
          ActAsPermissionControllable::Controller.set(self, options.slice(:index))

          def self.inherited(subclass)
            ActAsPermissionControllable::Controller.set(subclass, {})
            super
          end
        end

        def skip_grant_permission
          ActAsPermissionControllable::Controller.remove(self)
        end
      end
    end
  end
end

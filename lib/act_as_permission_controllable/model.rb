module ActAsPermissionControllable
  module Model
    extend ActiveSupport::Concern

    included do
      def ban(subject, *actions)
        control_permissions :ban, subject, *actions
        self
      end

      def permit(subject, *actions)
        control_permissions :permit, subject, *actions
        self
      end

      def assign_permissions(attributes)
        return if !attributes.respond_to?(:each)
        perms, controllers = {}, Controller.get_controllers.map { |c| [ c.to_s, c ] }.to_h
        attributes.each do |name, actions|
          next if !(Array === actions)
          next if (controller = controllers[name.to_s]).nil?
          perms[name.to_s] = controller.actions.map(&:to_s) & actions.map(&:to_s)
        end
        self.permissions = perms
      end

      def self.total_permission_count
        Controller.get_controllers.sum { |controller| controller.actions.size }
      end

      def permission_count
        c = 0
        Controller.get_controllers.each do |controller|
          if actions = self.permissions[controller.to_s]
            c += (controller.actions.map(&:to_s) & actions.map(&:to_s)).size
          end
        end
        c
      end

      def can?(*args)
        @current_ability ||= ::Ability.new(self)
        @current_ability.can?(*args)
      end

      after_commit do
        @current_ability = nil
      end

      private

        def control_permissions(type, subject, *actions)
          type = type.to_s

          if subject == :all
            Controller.get_controllers.each do |controller|
              if type == 'permit'
                self.permissions[controller.to_s] = controller.actions.map(&:to_s)
              elsif type == 'ban'
                self.permissions.delete(controller.to_s)
              end
            end
            return
          end

          subject = subject.to_s
          controller = Controller.get_controllers.find do |controller|
            name, key = controller.controller_name, controller.to_s
            subject == key || subject == name || subject == name.singularize
          end

          return if controller.nil?

          key = controller.to_s
          self.permissions[key] ||= []
          if actions == [ :all ]
            actions = controller.actions.map(&:to_s)
          else
            actions = actions.flatten.map(&:to_s)
          end
          if type == 'permit'
            self.permissions[key] += actions
          elsif type == 'ban'
            self.permissions[key] -= actions
          end
          self.permissions[key].uniq!
          self.permissions.delete(key) if self.permissions[key].empty?

          return
        end
    end
  end
end

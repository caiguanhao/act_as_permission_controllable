module ActAsPermissionControllable
  class Action
    def self.actions_for_controller(controller)
      controller.public_instance_methods(include_super = false).map { |action| self.new(action, controller) }
    end

    def initialize(action, controller)
      @action = action
      @controller = controller
    end

    def to_s
      @action.to_s
    end

    def controller
      @controller
    end

    def permitted_in?(permission_hash)
      actions = permission_hash[controller.to_s]
      (Array === actions) && actions.map(&:to_s).include?(to_s)
    end

    def i18n_name
      model = controller.controller_name.singularize
      model = I18n.translate(:"activerecord.models.#{model}")
      defaults = [
        :"act_as_permission_controllable.actions.#{to_s}",
        to_s,
      ]
      I18n.translate(:"act_as_permission_controllable.actions.#{controller.to_s}.#{to_s}",
                     model: model, default: defaults)
    end
  end
end

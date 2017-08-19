module ActAsPermissionControllable
  class Controller
    mattr_accessor :permission_controllable_controllers do
      Hash.new
    end

    mattr_accessor :preload_controller do
      -> {
        if ::Rails.application.config.cache_classes != true
          ::Dir["#{::Rails.root}/app/controllers/**/*_controller.rb"].each do |file|
            require file
          end
        end
      }
    end

    def self.set(controller, options)
      if !self.permission_controllable_controllers[controller.to_s]
        controller.authorize_resource(class: false) # cancancan
      end
      self.permission_controllable_controllers[controller.to_s] = options
    end

    def self.remove(controller)
      if self.permission_controllable_controllers[controller.to_s]
        self.permission_controllable_controllers.delete(controller.to_s)
        controller.skip_authorize_resource # cancancan
      end
    end

    def self.get_controllers(sorted: false)
      self.preload_controller.call if Proc === self.preload_controller
      controllers = self.permission_controllable_controllers.map { |controller, _|
        self.new(controller)
      }.select(&:controllable?)

      if sorted
        order = I18n.t('act_as_permission_controllable.order', default: [[]])
        controllers = controllers.sort_by(&:controller_name).sort_by.with_index { |controller, i|
          [ order.index(controller.to_s) || order.size, i ]
        }
      end

      controllers
    end

    def initialize(controller)
      @controller = case controller
                    when Symbol then controller.to_s.safe_constantize
                    when String then controller.safe_constantize
                    else controller
                    end
      @data = self.class.permission_controllable_controllers[@controller.to_s]
    end

    def nil?
      @controller.nil?
    end

    def controllable?
      !!@data && actions.present?
    end

    def controller_name
      @controller.controller_name
    end

    def to_s
      @controller.to_s
    end

    def i18n_name
      name = controller_name.singularize
      defaults = [
        :"activerecord.models.#{name}",
        name.camelize,
      ]
      I18n.translate(:"act_as_permission_controllable.controllers.#{to_s}", default: defaults)
    end

    def actions
      Action.actions_for_controller(@controller)
    end

    def index
      @data[:index].presence || :index
    end
  end
end

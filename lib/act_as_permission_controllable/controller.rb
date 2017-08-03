module ActAsPermissionControllable
  class Controller
    mattr_accessor :base_controller do
      -> {
        ::Admin::BaseController
      }
    end

    mattr_accessor :preload_controller do
      -> {
        if ::Rails.application.config.cache_classes != true
          ::Dir["#{::Rails.root}/app/controllers/admin/**/*_controller.rb"].each do |file|
            require file
          end
        end
      }
    end

    def self.get_controllers(sorted: false)
      self.preload_controller.call if Proc === self.preload_controller

      base_controller = self.base_controller
      base_controller = base_controller.call if base_controller.respond_to?(:call)

      return [] if !base_controller.respond_to?(:subclasses)
      controllers = base_controller.subclasses.map { |controller|
        self.new(controller)
      }.select(&:controllable?)

      controllers = controllers.sort_by(&:controller_name).sort_by.with_index { |controller, i|
        [-1 * controller.priority, i]
      } if sorted 

      controllers
    end

    def initialize(controller)
      @controller = case controller
                    when Symbol then controller.to_s.safe_constantize
                    when String then controller.safe_constantize
                    else controller
                    end
      @data = @controller.instance_variable_get(:'@__permission__')
    end

    def nil?
      @controller.nil?
    end

    def controllable?
      !!@data
    end

    def controller_name
      @controller.controller_name
    end

    def to_s
      @controller.to_s
    end

    def i18n_name
      defaults = [
        :"activerecord.models.#{controller_name.singularize}",
      ]
      I18n.translate(:"act_as_permission_controllable.controllers.#{to_s}", default: defaults)
    end

    def actions
      Action.actions_for_controller(@controller)
    end

    def index
      @data[:index].presence || :index
    end

    def priority
      @data[:priority].presence || 0
    end
  end
end

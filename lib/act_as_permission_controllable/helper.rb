module ActAsPermissionControllable
  module Helper
    def controllable_nav_items(user = current_admin, &block)
      @_controllable_nav_items ||= user.permissions.map do |controller_name, actions|
        controller = Controller.new(controller_name)
        next nil if controller.nil? || !controller.controllable?
        next nil if actions.map(&:to_s).exclude?(controller.index.to_s)
        controller
      end.compact.
      sort_by.with_index { |controller, i| [ controller.controller_name, i ] }.
      sort_by.with_index { |controller, i| [ -1 * controller.priority, i ] }
      block_given? ? @_controllable_nav_items.each(&block) : @_controllable_nav_items
    end

    def controllable_controllers
      @_controllable_controllers ||= Controller.get_controllers(sorted: true)
    end
  end
end

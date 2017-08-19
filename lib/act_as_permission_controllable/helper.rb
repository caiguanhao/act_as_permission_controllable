module ActAsPermissionControllable
  module Helper
    def controllable_nav_items(user = current_admin, &block)
      @_controllable_nav_items ||= controllable_controllers.select do |controller|
        actions = user.permissions[controller.to_s]
        actions && actions.map(&:to_s).include?(controller.index.to_s)
      end
      block_given? ? @_controllable_nav_items.each(&block) : @_controllable_nav_items
    end

    def controllable_controllers
      @_controllable_controllers ||= Controller.get_controllers(sorted: true)
    end
  end
end

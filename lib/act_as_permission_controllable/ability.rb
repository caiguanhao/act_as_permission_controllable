module ActAsPermissionControllable
  module Ability
    extend ActiveSupport::Concern

    included do
      include CanCan::Ability

      def initialize(user)
        return if !user || !(Hash === user.permissions)
        user.permissions.each do |controller_name, actions|
          controller = controller_name.safe_constantize
          next if controller.nil?
          can actions.map(&:to_sym), controller.controller_name.singularize.to_sym
        end
      end
    end
  end
end

require 'test_helper'

class ActAsPermissionControllable::Test < ActiveSupport::TestCase
  setup do
    ::Rails.application.config.cache_classes = false
  end

  def test_get_controllers
    c = ActAsPermissionControllable::Controller
    assert_equal [ 'Admin::AdminsController', 'Admin::UsersController' ], c.get_controllers.map(&:to_s)
  end

  def test_user_permit_and_ban
    user = admins(:foo)
    assert_equal({}, user.permissions)

    user.permit(:users, :index)
    assert_equal({ 'Admin::UsersController' => [ 'index' ] }, user.permissions)

    user.permit(:all)
    assert_equal Set.new(%w{Admin::AdminsController Admin::UsersController}), Set.new(user.permissions.keys)

    user.ban(:admin, :all)
    assert_equal [ 'Admin::UsersController' ], user.permissions.keys

    assert_equal Set.new(%w{index show new create edit update destroy}), Set.new(user.permissions['Admin::UsersController'])

    user.ban(:users, :create, :update, :destroy)
    assert_equal Set.new(%w{index show new edit}), Set.new(user.permissions['Admin::UsersController'])

    user.ban(:all)
    assert_equal({}, user.permissions)
  end

  def test_user_can
    user = admins(:foo)
    assert_not user.can?(:destroy, :user)

    user.permit(:users, :destroy)
    user.save!

    assert user.can?(:destroy, :user)
  end
end

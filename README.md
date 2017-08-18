# ActAsPermissionControllable

*Control user / admin permissions with cancancan.*

Easily integrate cancancan into your application with permission control of every controller action.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'act_as_permission_controllable'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install act_as_permission_controllable
```

## Migration
Add a `permissions` JSONB field to your model:

```bash
rails g migration AddPermissionsToAdmins permissions:jsonb
```

Add `default: {}, nil: false`:

```ruby
class AddPermissionsToAdmins < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :permissions, :jsonb, default: {}, nil: false
  end
end
```

## Model
Add `act_as_permission_controllable` to your model:

```ruby
class Admin < ApplicationRecord
  act_as_permission_controllable # methods added: ban, permit, assign_permissions, can?
end
```

Create `app/models/ability.rb`:
```ruby
class Ability
  include ActAsPermissionControllable::Ability
end
```

## Controller
Add `grant_permission` to your base controller.
Controllers inherited from it will need authorization.
You can rescue from `CanCan::AccessDenied` error to show permission error message.
You also need to define `current_ability` for `cancancan` to work.
```ruby
class Admin::BaseController < ApplicationController

  # ... other code ...

  grant_permission

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json {
        render json: { message: exception.message }, status: 403
      }
      format.html {
        render 'act_as_permission_controllable/forbidden', layout: 'admin', status: 403, locals: { exception: exception }
      }
    end
  end

  private

    def current_ability
      @current_ability ||= Ability.new(current_admin)
    end

  # ... other code ...
end
```

If you don't want a controller to check user permission, use `skip_grant_permission`.
```ruby
class Admin::HomeController < Admin::BaseController
  skip_grant_permission
end
```

To edit permissions on the web page, add actions to your routes:
```ruby
resources :admins do
  member do
    match :permissions, via: [ :get, :post ]
  end
end
```

And in your controller:
```ruby
class Admin::AdminsController < Admin::BaseController
  # ... other code ...

  def permissions
    if request.post?
      @admin.assign_permissions(params.fetch(:actions, []))
      if @admin.save
        flash[:notice] = 'OK!'
      else
        flash[:error] = 'ERROR!'
      end
      redirect_to params[:referer].presence || permissions_admin_admin_path(@admin)
      return
    end

    render 'act_as_permission_controllable/permissions'
  end

  # ... other code ...
end
```

## View
You can use `controllable_nav_items` to list permitted pages for current user:
```eruby
<ul class="nav navbar-nav">
  <% controllable_nav_items do |item| %>
    <%= content_tag :li, class: (name = item.controller_name) == controller.controller_name ? 'active' : nil do %>
      <%= link_to item.i18n_name, url_for(controller: name, action: item.index) rescue nil %>
    <% end %>
   <% end %>
</ul>
```

## I18n
You can customize the names of each controller action:
```yaml
# config/locales/aapc.en.yml
en:
  act_as_permission_controllable:
    controllers:
      Admin::AdminsController:   'Admins'
      Admin::OrdersController:   'Orders'
      Admin::SettingsController: 'Settings'
    actions:
      Admin::AdminsController:
        permissions: 'View and Set Permissions'
      Admin::OrdersController:
        export: 'Export Orders'
```

## Contributing

You can open issues or pull requests on [GitHub](https://github.com/caiguanhao/act_as_permission_controllable).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

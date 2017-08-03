Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  constraints lambda { |request| request.subdomains.first == 'admin' } do
    namespace 'admin', path: '/', host: 'admin.localhost.com' do
      root to: redirect('/users')

      resources :admins do
        collection do
          get :welcome
        end
        member do
          match :permissions, via: [ :get, :post ]
        end
      end

      resources :users

      scope controller: :language do
        post :toggle_language
      end
    end
  end

end

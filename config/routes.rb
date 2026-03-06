Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "/register", to: "auth#register"
      post "/login",    to: "auth#login"

      resources :products, only: [ :index, :show ] do
        member do
          get :recommendations
        end

        collection do
          get :search
        end
      end

      resource :cart, only: [ :show ], controller: "carts" do
        post   "add_item"
        delete "remove_item"
      end

      resource :wishlist, only: [ :show ], controller: "wishlists" do
        post   "add_item"
        delete "remove_item/:product_id", action: :remove_item
        post "move_to_cart"
      end

      resources :orders, only: [ :create, :index, :update ]

      namespace :admin do
        resources :products
        resources :users
        resources :orders, only: [ :index, :show, :update ]
      end
    end
  end
end

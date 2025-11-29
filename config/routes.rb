Rails.application.routes.draw do
  # Devise + ActiveAdmin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise routes for customers
  devise_for :customers

  # Products front-end
  root "products#index"
  resources :products, only: [ :index, :show ]

  # Shopping Cart
  resource :cart, only: [ :show ] do
    post   "add/:product_id",    to: "carts#add",    as: :add
    patch  "update/:product_id", to: "carts#update", as: :update
    delete "remove/:product_id", to: "carts#remove", as: :remove
  end

  # Checkout
  get  "/checkout",         to: "checkouts#new",     as: :checkout
  post "/checkout_confirm", to: "checkouts#confirm", as: :checkout_confirm

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # About / Contact
  get "/about",   to: "pages#show", defaults: { name: "about" }
  get "/contact", to: "pages#show", defaults: { name: "contact" }
end

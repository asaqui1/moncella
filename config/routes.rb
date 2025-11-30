Rails.application.routes.draw do
  # Devise + ActiveAdmin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

# Devise routes for customers with custom controller
devise_for :customers, path: "customers", controllers: {
  registrations: "customers/registrations"
}

  # Products front-end
  root "products#index"
  resources :products, only: [ :index, :show ]

  # Shopping Cart
  resource :cart, only: [ :show ] do
    post   "add/:product_id",    to: "carts#add",    as: :add
    patch  "update/:product_id", to: "carts#update", as: :update
    delete "remove/:product_id", to: "carts#remove", as: :remove
  end

  # Customer Orders
  resources :orders, only: [ :index, :show ]

  # Checkout
  get  "/checkout",         to: "checkouts#new",     as: :checkout
  post "/checkout_confirm", to: "checkouts#confirm", as: :checkout_confirm

  # Payment
  get  "/payment",         to: "payments#show",    as: :payment
  get  "/payment/success", to: "payments#success", as: :payment_success
  get  "/payment/cancel",  to: "payments#cancel",  as: :payment_cancel

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # About / Contact
  get "/about",   to: "pages#show", defaults: { name: "about" }
  get "/contact", to: "pages#show", defaults: { name: "contact" }
end

Rails.application.routes.draw do
  get 'no_users_yet', to: 'admin/users#no_users_yet', as: :no_users_yet
  root 'dashboard#index'
  devise_for :users, controllers: { registrations: 'users/registrations' }
  get 'dashboard/index'

  resources :stocks, only: [:index, :show]
  get 'search_stock', to: 'stocks#search'
  post 'buy_stock', to: 'stocks#buy'
  get 'my_portfolio', to: 'portfolio#index'
  get 'sell_stock/:ticker', to: 'portfolio#sell', as: 'sell_stock'
  post 'sell_stock', to: 'portfolio#confirm_sell'
  resources :transactions, only: [:index]

  namespace :admin do
    resources :users do
      patch :reject, on: :member
    end
    resources :pending_traders, only: [:index, :update, :destroy]
    resources :transactions, only: [:index]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  # Catch-all route for unmatched paths (must be last)
  match '*unmatched', to: 'application#render_not_found', via: :all
end

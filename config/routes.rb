Rails.application.routes.draw do
  get 'users/show'

  root 'homes#index'
  get 'homes/index'

  resource :user, expect: [:destroy, :new, :create]
  resources :reminders, only: [:create, :destroy]

  #OmniAuth
  match "/auth/:provider/callback", to: "sessions#create", via: 'get'
  match "/logout", to: "sessions#destroy", via: 'get'
end

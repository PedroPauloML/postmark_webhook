Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  default_url_options :host => "localhost:3000"

  post 'email_processor', to: 'email_processor#create', as: 'email_processor'
  resources :emails

  root 'emails#index'
end

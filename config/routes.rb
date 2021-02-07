Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'email_processor', to: 'email_processor#create', as: 'email_processor'
end

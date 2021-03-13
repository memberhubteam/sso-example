Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/auth', to: 'auth#create', as: :auth
  get '/auth/callback', to: 'auth#update', as: :callback
end

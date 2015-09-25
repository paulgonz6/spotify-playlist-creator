Rails.application.routes.draw do
  resources :users

  root "static_pages#home"

  get "/auth/spotify", :as => :sign_in
  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout_user
  get '/add_to_playlist/:id/:playlist/:track' => "users#add_to_playlist", :as => :add_to_playlist

end

Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  #get 'sessions/new' # rails generate default routing set
  #get 'users/new'
  root "static_pages#home"
  get    "/help",    to: "static_pages#help"
  get    "/about",   to: "static_pages#about"
  get    "/contact", to: "static_pages#contact"
  get    "/signup", to: "users#new"
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"
  resources :users do
    member do
      get :following, :followers
    end
  end  
  resources :users
  resources :account_activations, only: [:edit]
  #resources :password_resets,     only: [:new, :create, :edit, :update]
  # 2024.06.12 feed検索が動作しなくなったので修正。POSTとRANSACKがバッティングしていると思われる
  #resources :microposts do
  #  member do
  #    post :show
  #  end
  #end
  resources :microposts,          only: [:show, :create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  get '/microposts', to: 'static_pages#home'
end

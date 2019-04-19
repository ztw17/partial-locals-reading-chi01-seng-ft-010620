Rails.application.routes.draw do
  resources :authors, only: [:index, :show]
  resources :posts, only: [:index, :show]
end

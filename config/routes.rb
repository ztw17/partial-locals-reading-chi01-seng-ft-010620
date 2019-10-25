Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :authors, only: [:index, :show]
  resources :posts, only: [:index, :show]

  root 'posts#index'
end

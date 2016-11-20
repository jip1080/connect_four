Rails.application.routes.draw do
  # You can have the root of your site routed with "root"
  root to: 'welcome#index'

  resources :players, only: [:index, :new, :create, :show] do
  end

  resources :games, only: [:index, :new, :create, :show] do
    post '/update_board', to: 'games#update_board'
  end
end

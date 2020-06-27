Rails.application.routes.draw do
  get 'comments/create'
  get 'comments/update'
  get 'comments/destroy'
  get "movies/search", to: "movies#search", as: "search_movie"
  get 'movies', to: "movies#index", as: "movies"
  get 'movies/new', to: "movies#new", as: "new_movie"
  get 'movies/:id', to: "movies#show", as: "movie"
  post 'movies', to: "movies#create"
  put 'movies/:id', to: "movies#update"
  get 'movies/:id/edit', to: "movies#edit", as: "edit_movie"
  delete 'movies/:id', to: "movies#destroy"

  root "movies#index"

  resources :movies do
    resources :comments
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

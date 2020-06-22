Rails.application.routes.draw do
  get 'movies/index'
  get 'movies/show'
  get 'movies/new'
  get 'movies/edit'
  get 'movies/create'
  get 'movies/update'
  get 'movies/destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

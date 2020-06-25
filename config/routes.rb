Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :customers, only: [:index]

  resources :movies, only: [:index, :show, :create], param: :title

  resources :rentals, only: [:index] #just to see seed data in the API
 
  #path to get rentals that are currently checked out
  #I know this path name is long. Too bad!
  get "/rentals/currentlycheckedout", to: "rentals#currentlycheckedout", as: "currentlycheckedout"

  post "/rentals/:title/check-out", to: "rentals#check_out", as: "check_out"
  post "/rentals/:title/return", to: "rentals#check_in", as: "check_in"
  get "/rentals/overdue", to: "rentals#overdue", as: "overdue"

  root 'movies#index'

end
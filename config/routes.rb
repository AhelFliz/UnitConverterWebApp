Rails.application.routes.draw do
  resources :dashboard
  root "dashboard#index"
end

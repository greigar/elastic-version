Rails.application.routes.draw do
  resources :conversations
  get 'search', to: 'conversations#search'
  root 'conversations#search'
end

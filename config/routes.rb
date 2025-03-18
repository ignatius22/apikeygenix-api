Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: { sign_in: 'login', sign_out: 'logout', registration: 'signup' },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  get '/me', to: 'users/sessions#me'

  namespace :api do
    namespace :v1 do
      resources :api_keys, only: [:index, :create, :destroy] do
        member do
          patch 'use'
        end
      end
    end
  end

  # Add root route
  root to: 'application#root'
end
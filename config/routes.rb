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
      get '/weather', to: 'weather#show'
      get '/dashboard', to: 'dashboard#show' # New endpoint
      post '/code_feedback', to: 'code_feedback#create'
    end
  end

  # Add root route
  root to: 'application#root'
end
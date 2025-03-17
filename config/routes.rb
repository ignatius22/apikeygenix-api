Rails.application.routes.draw do
  devise_for :users,
             path: '', # Removes /users prefix for cleaner API routes
             path_names: { sign_in: 'login', sign_out: 'logout', registration: 'signup' },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  namespace :api do
    namespace :v1 do
      resources :api_keys, only: [:index, :create, :destroy] do
        member do
          patch 'use' # Adds PATCH /api/v1/api_keys/:id/use
        end
      end
    end
  end
end
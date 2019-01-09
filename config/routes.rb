Rails.application.routes.draw do
  # devise_for :users
  namespace :api do
    resources :users, only: [] do
      collection do
        post :sign_up
        post :sign_in
        delete :sign_out
      end
    end

    resources :artists
    resources :songs
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations], path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register",
  }
  as :user do
    put    "/account",  to: "users/registrations#update"
    delete "/account",  to: "users/registrations#destroy"
    post   "/account", to: "users/registrations#create"
    get    "/register", to: "users/registrations#new", as: :new_user_registration
    get    "/account", to: "users/registrations#edit", as: :edit_user_registration
    patch  "/account", to: "users/registrations#update", as: :user_registration
    get    "/account/cancel", to: "users/registrations#cancel", as: :cancel_user_registration
  end

  root to: "home#index"
end

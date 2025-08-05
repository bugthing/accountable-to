Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Home page and signup
  root "home#index"
  post "signup", to: "home#signup"
  post "send_magic_link", to: "home#send_magic_link"

  # User confirmation and authentication
  get "confirm/:token", to: "users#confirm", as: :confirm_user
  get "confirmed", to: "users#confirmed"
  get "magic_login/:token", to: "users#magic_login", as: :magic_login
  delete "logout", to: "users#logout"

  # Goals management
  resources :goals, only: [:new, :create, :show, :index, :destroy]

  # Dashboard (after login)
  get "dashboard", to: "goals#index"

  # Legal pages
  get "legal/privacy-policy", to: "home#privacy_policy"
end

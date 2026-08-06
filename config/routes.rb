Rails.application.routes.draw do
  root "home#index"

  get "onboarding/:step", to: "onboarding#show", as: :onboarding
  patch "onboarding/:step", to: "onboarding#update"

  get "/admin/login", to: "admin#login", as: :admin_login
  post "/admin/login", to: "admin#authenticate", as: :admin_authenticate
  get "/admin", to: "admin#dashboard", as: :admin_dashboard
  delete "/admin/logout", to: "admin#logout", as: :admin_logout

  get "/asteroids/:id", to: "asteroids#show", as: :asteroid
  get "/plans/:id", to: "plans#show", as: :plan
end

WheelerBoard::Application.routes.draw do
  devise_for :employees, controllers: { omniauth_callbacks: "employees/omniauth_callbacks" }
  devise_scope :employees do
    resource :employee do
      resource :profile
    end
  end
  resource :status
  resources :wheelers
  root to: 'home#index'
end

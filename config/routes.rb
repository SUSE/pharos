# frozen_string_literal: true
Rails.application.routes.draw do
  get "updates/index"
  get "nodes/index"

  devise_for :users, controllers: { registrations: "auth/registrations",
                                    sessions:      "auth/sessions" }

  resource :dashboard, only: [:index]

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  devise_scope :user do
    root to: "auth/sessions#new"
  end

  get '/ui-demo/1', to: 'demo#1'
  get '/ui-demo/2', to: 'demo#2'
  get '/ui-demo/3', to: 'demo#3'
  get '/ui-demo/4', to: 'demo#4'
  get '/ui-demo/5', to: 'demo#5'
  get '/ui-demo/6', to: 'demo#6'

  resources :nodes, only: [:index, :show, :destroy] do
    collection do
      put :update
      post :bootstrap
    end
  end
  resources :updates, only: [:index]
  resources :admin, only: [:index]
end

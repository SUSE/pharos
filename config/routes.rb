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

  get '/installer/options', to: 'installer#options'
  get '/installer/master', to: 'installer#master'
  get '/nodes/new', to: 'nodes#new'
  get '/nodes', to: 'nodes#list'
  get '/config', to: 'config#index'

  resources :nodes, only: [:index, :show, :destroy] do
    collection do
      put :update
      post :bootstrap
    end
  end
  resources :updates, only: [:index]
  resources :admin, only: [:index]
end

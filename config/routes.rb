Rails.application.routes.draw do
  root "mulah#index"
  resources :mulah
  get '/', to: 'mulah#index'
end

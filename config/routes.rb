Rails.application.routes.draw do

  mount DelayedJobWeb, at: "/delayed_job"

  get 'pages/contact', to: 'pages#contact', as: 'contact'

  get 'pages/permissions', to: 'pages#permissions', as: 'permissions'

  get 'pages/copyrightinformation', to: 'pages#copyrightinformation', as: 'copyrightinformation'

  get 'pages/interviewguidelines', to: 'pages#interviewguidelines', as: 'interviewguidelines'

  get 'pages/familyhistory', to: 'pages#familyhistory', as: 'familyhistory'

  get 'pages/programs', to: 'pages#programs', as: 'programs'

  get 'pages/organizations', to: 'pages#organizations', as: 'organizations'

  get 'pages/training', to: 'pages#training', as: 'training'

  get 'pages/bibliography', to: 'pages#bibliography', as: 'bibliography'

  get '/admin', to: 'admin#index', as: 'admin'

  get 'admin/run_import', to: 'admin#run_import', as: 'run_import'

  mount Blacklight::Engine => '/'
  Blacklight::Marc.add_routes(self)
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :interviewee, only: [:index], as: 'interviewee', path: '/interviewee', controller: 'interviewee' do
    concerns :searchable
  end

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

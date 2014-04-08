# if used in cbu_loadup, all full_links are modified to have prefix 
# this will be used in the get route as well then
CONTENT_LINK_PREFIX = '/d'

CouchbaseUniversity::Application.routes.draw do
  
  get "/qa" => 'qa#index'
	get "/qanda" => 'qa#index'  
	get "/q-and-a" => 'qa#index'  
  get "/q/:question" => 'qa#question'
	get "/qa/tags/:tags" => 'qa#by_tag'

  get '/blogs' => 'blogs#index'
  get '/blogs/couchbase' => 'blogs#couchbase'
  get '/blogs/community' => 'blogs#community'
  
  get '/results' => 'search#results'  
  
  get '/videos' => 'videos#index'
  get '/video/:id' => 'videos#index'

  get '/training' => 'training#index'
  get '/training/:id' => 'training#course'
  
  #get '/*article_id/images/:image_id' => 'docs#article_images'

  get '/d', to: 'docs#article', defaults: { document_id: 'home' }
	get "#{CONTENT_LINK_PREFIX}/*node_id/images/:asset_id", to: 'docs#article_images', constraints: { node_id: /[\-\/.A-ZA-z\d]+/, asset_id: /[\-\/.A-ZA-z\d]+/ }  
	get "#{CONTENT_LINK_PREFIX}/*document_id", to: 'docs#article', constraints: { document_id: /[\-\/.A-ZA-z\d]+/ }
	
  
  # AJAX Methods
  get '/sofeed' => 'main#sofeed'
  
  get '/cache_all' => 'docs#cache_nav_and_render'
  
	match '/persona/login' => 'auth#persona_login', via: [:get, :post]	
	match '/login' => 'auth#login', via: [:get, :post]

	match '/persona/logout' => 'auth#persona_logout', via: [:get, :post]
	match '/logout' => 'auth#logout', via: [:get, :post]
	
  root 'main#index'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  # You can have the root of your site routed with 'root'
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

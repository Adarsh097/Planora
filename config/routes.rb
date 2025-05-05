
Rails.application.routes.draw do
  # Mounting the Grape API
  # mount EventManager::Base => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'
 
  # mount V1::Base => '/api'
  mount V1::Users => '/api'
  mount V1::Events => '/api'

end

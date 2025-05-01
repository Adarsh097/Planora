Rails.application.routes.draw do
  # Mounting the Grape API
  # mount EventManager::Base => '/'
  mount V1::Users => '/api'
  mount V1::Events => '/api'

end

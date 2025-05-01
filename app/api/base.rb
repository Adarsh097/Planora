module EventManager
    class Base < Grape::API
      prefix 'api'
      format :json
  
      mount V1::Users
      mount V1::Events
    end
end
  
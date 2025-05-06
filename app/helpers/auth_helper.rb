module Helpers
    module AuthHelper
      extend Grape::API::Helpers
  
      def current_user
        token = headers['Authorization']&.split(' ')&.last
        decoded = JsonWebToken.decode(token)
        @current_user ||= User.find_by(id: decoded[:user_id]) if decoded
      end
  
      def authenticate!
        error!('Unauthorized', 401) unless current_user
      end
    end
  end
  
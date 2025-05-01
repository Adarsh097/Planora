class Api::AuthController < ApplicationController
    def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id, role: user.roel)
            render json: {
                status: :200,
                message: 'Login successful',
                token: token,
            }
        else
            render json:{
                status: :401,
                message: 'Invalid email or password'
            }
        end
    end
end
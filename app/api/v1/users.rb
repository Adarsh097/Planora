module V1
    class Users < Grape::API
        version 'v1', using: :path

        resource :users do
            desc 'Register a new user'
            params do
                requires :name, :email, :password, :address, :mobile_no, type: String
                optional :role, type: String, values: ['user', 'organiser'], default: 'user'
            end

            post '/register' do
                user = User.new(
                    name: params[:name],
                    email: params[:email],
                    password: params[:password],
                    address: params[:address],
                    mobile_no: params[:mobile_no],
                    role: params[:role] || 'user'
                )

                if user.save
                    user_data = user.as_json(only: [:id, :name, :email, :address, :mobile_no, :role])

                    { status: 201, message: 'User registered successfully', user: user_data }
                else
                    error!({ status: 422, message: 'User registration failed', errors: user.errors.full_messages }, 422)
                end
            end

            desc 'Login a user'
            params do
                requires :email, type: String
                requires :password, type: String
            end
            post '/login' do
                user = User.find_by(email: params[:email])
                if user && user.authenticate(params[:password])
                    token = JsonWebToken.encode(user_id: user.id, role: user.role)
                    { status: 200, message: 'Login successful', token: token }
                else
                    error!({ status: 401, message: 'Invalid email or password' }, 401)
                end
            end
        end
    end
end
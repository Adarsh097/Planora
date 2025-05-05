module EventManager
    class Base < Grape::API
      prefix 'api'
      format :json
  
      mount V1::Users
      mount V1::Events

      # Add Swagger documentation
    add_swagger_documentation(
      api_version: 'v1',
      info: {
        title: 'Events API',
        description: 'API documentation for the Events app'
      },
      hide_format: true,
      mount_path: '/swagger_doc',
      base_path: '/',
      hide_documentation_path: false
    )
    end
end
  
module V1
    class Events < Grape::API
      version 'v1', using: :path
        
      format :json

        
      helpers do
        def current_user
          token = headers['Authorization']&.split(' ')&.last
          decoded = JsonWebToken.decode(token)
          @current_user ||= User.find_by(id: decoded[:user_id]) if decoded
        end
  
        def authenticate!
          error!('Unauthorized', 401) unless current_user
        end
      end
  
      resource :events do
        before { authenticate! }
  
        desc 'Get all events'
        get do
          Event.all
        end
  
        desc 'Create an event (organiser only)'
        params do
          requires :title, type: String
          requires :date, type: String, desc: 'Date and time in ISO8601 format (e.g. 2025-05-05T16:30)'
          optional :description, type: String
        end
        post do
          error!('Only organisers can create events', 403) unless current_user.organiser?
        
          begin
            event_time = Time.zone.parse(params[:date]) # parses into IST if time zone is set
          rescue ArgumentError
            error!({ error: 'Invalid date format. Use ISO8601, e.g., 2025-05-05T16:30' }, 400)
          end
        
          event = current_user.events.build(
            title: params[:title],
            description: params[:description],
            date: event_time
          )
        
          if event.save
            event
          else
            error!({ error: event.errors.full_messages }, 400)
          end
        end
        
  
        desc 'Update an event (organiser only)'
        params do
          requires :id, type: Integer
          optional :title, :description, :date, type: String
        end
        put ':id' do
          error!('Only organisers can update events', 403) unless current_user.organiser?
  
          event = current_user.events.find(params[:id])
          if event.update(
            title: params[:title],
            description: params[:description],
            date: params[:date]
          )
            event
          else
            error!({ error: event.errors.full_messages }, 400)
          end
        end
  
        desc 'Delete an event (organiser only)'
        params do
          requires :id, type: Integer
        end
        delete ':id' do
          error!('Only organisers can delete events', 403) unless current_user.organiser?
  
          event = current_user.events.find(params[:id])
          event.destroy
          { message: 'Event deleted' }
        end


        desc 'View all Users registered for an event (organiser only)'
        params do
          requires :id, type: Integer, desc: 'Event ID'
        end

        get ':id/registrations' do  
        error!('Only organisers can view registrations', 403) unless current_user.organiser?
        event = Event.find(params[:id])
        error!('Event not found', 404) unless event
        registrations = EventRegistration.where(event: event).includes(:user)
        if registrations.empty?
          { message: 'No registrations found for this event' }
        else
          users = registrations.map(&:user)
          users.as_json(only: [:id, :name, :email, :address, :mobile_no])
        end
        end
          
  
        desc 'Join an event (user only)'
        params do
          requires :id, type: Integer
        end
        post ':id/join' do
          error!('Only users can join events', 403) unless current_user.user?
  
          event = Event.find(params[:id])
          registration = EventRegistration.new(user: current_user, event: event)
  
       
            if registration.save
              
              EventMailer.user_joined_event(current_user.id, event.id).deliver_now


    
            { message: 'Successfully joined event' }
          else
            error!({ error: registration.errors.full_messages }, 400)
          end
        end



        desc 'Unregister from an event (user only)'
        params do
          requires :id, type: Integer
        end
        delete ':id/leave' do
          error!('Only users can leave events', 403) unless current_user.user?

          event = Event.find(params[:id])
          error!('Event not found',404) unless event

          registration = EventRegistration.find_by(user: current_user, event: event)
          error!('Not registered for this event', 404) unless registration

          if registration.destroy
            {status: 200, message: 'Successfully left event'}
          else
            error!({error: registration.errors.full_messages}, 400)
          end
        end

        desc 'Get all the events a user is registered for'
        get 'my_events' do
          error!('Only users can view their events', 403) unless current_user.user?

          registrations = EventRegistration.where(user: current_user)
          events = registrations.map(&:event)

          if events.empty?
            { message: 'No events found' }
          else
            events
          end
        end

      end
    end
  end
  
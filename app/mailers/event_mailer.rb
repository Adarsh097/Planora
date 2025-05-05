# app/mailers/event_mailer.rb
class EventMailer < ApplicationMailer
    def user_joined_event(user, event)
        @user = User.find(user)
        @event = Event.find(event)
    
      mail(to: @user.email, subject: "You joined the event #{@event.title}")
    end
  end
  
class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(user_id, event_id)
    user = User.find(user_id)
    event = Event.find(event_id)
    EventMailer.user_joined_event(user, event).deliver_now
  end
end
